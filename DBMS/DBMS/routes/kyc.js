const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const { pool } = require('../db/connection');
const { requireAdmin, authenticateToken } = require('../middleware/auth');
const cryptoUtils = require('../utils/crypto');

// POST /api/kyc/upload
// Expects: { documentType: 'AADHAAR', fileName: 'doc.pdf', mimeType: 'application/pdf', fileData: 'base64_string' }
router.post('/upload', authenticateToken, async (req, res) => {
  try {
    const { documentType, fileName, mimeType, fileData } = req.body;
    if (!fileData) return res.status(400).json({ error: 'Missing fileData' });

    const buffer = Buffer.from(fileData, 'base64');
    const fileSize = buffer.length;

    // Encrypt the buffer
    const iv = crypto.randomBytes(16);
    const key = Buffer.from(cryptoUtils.ENCRYPTION_KEY, 'hex');
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
    
    let encrypted = Buffer.concat([cipher.update(buffer), cipher.final()]);
    const authTag = cipher.getAuthTag();

    const documentHash = crypto.createHash('sha256').update(buffer).digest('hex');
    const storageName = crypto.randomBytes(16).toString('hex');

    await pool.query(
      `INSERT INTO KYC_Document (customer_id, document_type, storage_name, encrypted_document, encryption_iv, encryption_auth_tag, original_file_name, mime_type, file_size, document_hash) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [req.user.customerId, documentType || 'AADHAAR', storageName, encrypted, iv, authTag, fileName || 'upload.bin', mimeType || 'application/octet-stream', fileSize, documentHash]
    );

    res.json({ message: 'KYC Document uploaded successfully' });
  } catch (error) {
    console.error('KYC upload error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/kyc/admin/documents (for admin overview)
router.get('/admin/documents', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const [docs] = await pool.query('SELECT * FROM vw_kyc_overview');
    res.json({ documents: docs });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// POST /api/kyc/admin/verify (for admin to verify/reject)
router.post('/admin/verify', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { documentId, status, rejectionReason } = req.body;
    await pool.query(
      `UPDATE KYC_Document SET verification_status = ?, verified_at = CURRENT_TIMESTAMP, verified_by = ?, rejection_reason = ? WHERE document_id = ?`,
      [status, req.user.authId, rejectionReason || null, documentId]
    );
    res.json({ message: 'Document status updated.' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;

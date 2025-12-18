-- Create verification_codes table for email and phone verification
CREATE TABLE IF NOT EXISTS verification_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code VARCHAR(6) NOT NULL,
  type VARCHAR(10) NOT NULL CHECK (type IN ('email', 'phone')),
  verified BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  verified_at TIMESTAMP
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_verification_codes_user_id ON verification_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_codes_code ON verification_codes(code);
CREATE INDEX IF NOT EXISTS idx_verification_codes_type ON verification_codes(type);

-- Add comments for documentation
COMMENT ON TABLE verification_codes IS 'Stores verification codes for email and phone number verification';
COMMENT ON COLUMN verification_codes.user_id IS 'Reference to the user being verified';
COMMENT ON COLUMN verification_codes.code IS '6-digit verification code';
COMMENT ON COLUMN verification_codes.type IS 'Type of verification: email or phone';
COMMENT ON COLUMN verification_codes.verified IS 'Whether the code has been successfully verified';
COMMENT ON COLUMN verification_codes.expires_at IS 'Expiration timestamp (typically 15 minutes from creation)';
COMMENT ON COLUMN verification_codes.verified_at IS 'Timestamp when code was verified';

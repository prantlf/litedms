const {
  LITEDMS_URL,
  LITEDMS_HOST,
  LITEDMS_PORT
} = process.env

const host = LITEDMS_HOST === '0.0.0.0' && '127.0.0.1' || LITEDMS_HOST || '127.0.0.1'
const port = +(LITEDMS_PORT || 8020)

export const serviceUrl = LITEDMS_URL || `http://${host}:${port}`

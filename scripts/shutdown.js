import { postJson } from './shared/safe-fetch.js'
import settings from './shared/settings.json' assert { type: 'json' }
const { serviceUrl } = settings

await postJson(`${serviceUrl}/shutdown`)

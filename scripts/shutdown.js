import { postJson } from './shared/safe-fetch.js'
import { serviceUrl } from './shared/settings.js'

await postJson(`${serviceUrl}/shutdown`)

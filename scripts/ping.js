import { getJson } from './shared/safe-fetch.js'
import { serviceUrl } from './shared/settings.js'

await getJson(`${serviceUrl}/ping`)

import { getText } from './shared/safe-fetch.js'
import settings from './shared/settings.json' assert { type: 'json' }
const { serviceUrl } = settings

console.log(await getText(`${serviceUrl}/texts`))

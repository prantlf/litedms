import { getText } from './shared/safe-fetch.js'
import { serviceUrl } from './shared/settings.js'

console.log(await getText(`${serviceUrl}/texts`))

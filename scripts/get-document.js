import { getText } from './shared/safe-fetch.js'
import settings from './shared/settings.json' assert { type: 'json' }
const { serviceUrl } = settings

let [,, group, name] = process.argv
name = `${group}/${name}`
console.log(name)
console.log(await getText(`${serviceUrl}/texts/${encodeURIComponent(name)}`))

import { drop } from './shared/safe-fetch.js'
import { serviceUrl } from './shared/settings.js'

let [,, group, name] = process.argv
name = `${group}/${name}`
console.log(name)
await drop(`${serviceUrl}/texts/${encodeURIComponent(name)}`)

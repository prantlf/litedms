import { getText } from './shared/safe-fetch.js'
import { serviceUrl } from './shared/settings.js'

let [,, group, name] = process.argv
name = `${group}/${name}`
console.log(name)
console.log(await getText(`${serviceUrl}/texts/${encodeURIComponent(name)}`))

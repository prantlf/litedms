import { readFile } from 'fs/promises'
import { dirname, join } from 'path'
import { fileURLToPath } from 'url'
import { putText } from './shared/safe-fetch.js'
import { serviceUrl } from './shared/settings.js'

const __dirname = dirname(fileURLToPath(import.meta.url))
const datadir = join(__dirname, '../data')

let [,, group, name] = process.argv
name = `${group}/${name}`
console.log(name)
const content = await readFile(join(datadir, `${name}.txt`), 'utf8')
await putText(`${serviceUrl}/texts/${encodeURIComponent(name)}`, content)

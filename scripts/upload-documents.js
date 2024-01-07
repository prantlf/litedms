import { readFile } from 'fs/promises'
import { join } from 'path'
import { putText } from './shared/safe-fetch.js'
import { enumerate } from './shared/documents.js'
import settings from './shared/settings.json' assert { type: 'json' }
const { serviceUrl } = settings

async function addFile(datadir, group, file) {
  const name = `${group}/${file.slice(0, -4)}`
  console.log(name)
  const content = await readFile(join(datadir, group, file), 'utf8')
  await putText(`${serviceUrl}/texts/${encodeURIComponent(name)}`, content)
}

await enumerate(addFile)

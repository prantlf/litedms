import { drop } from './shared/safe-fetch.js'
import { enumerate } from './shared/documents.js'
import settings from './shared/settings.json' assert { type: 'json' }
const { serviceUrl } = settings

async function deleteFile(_datadir, group, file) {
  const name = `${group}/${file.slice(0, -4)}`
  console.log(name)
  await drop(`${serviceUrl}/texts/${encodeURIComponent(name)}`)
}

await enumerate(deleteFile)

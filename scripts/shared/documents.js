import { readdir } from 'fs/promises'
import { dirname, join } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const datadir = join(__dirname, '../../data')

async function enumerateGroup(group, callback) {
  const files = await readdir(join(datadir, group))
  // await Promise.all(files
  //   .filter(file => file.endsWith('.txt'))
  //   .map(file => callback(datadir, group, file)))
  for (const file of files) {
    if (file.endsWith('.txt')) await callback(datadir, group, file)
  }
}

export async function enumerate(callback) {
  const groups = await readdir(datadir)
  // await Promise.all(groups
  //   .filter(dir => dir !== 'extra' && !dir.includes('.'))
  //   .map(dir => enumerateGroup(dir, callback)))
  for (const dir of groups) {
    if (dir !== 'extra' && !dir.includes('.')) await enumerateGroup(dir, callback)
  }
}

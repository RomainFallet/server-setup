import * as path from 'node:path'
import * as url from 'node:url'

const dirname = path.dirname(url.fileURLToPath(import.meta.url))

const getBasePath = () => {
  return path.join(dirname, '../')
}

const getFirstArgument = () => {
  const firstArgumentIndex = 2
  return process.argv[firstArgumentIndex]
}



export { getFirstArgument, dirname, getBasePath }

import fs, { readFileSync } from "fs";
import path from "path";

type FileType = {
  name: string,
  content: string
}

class Loader {
  resourceDir: string = GetResourcePath(GetCurrentResourceName());
  rootPath: string = this.resourceDir;
  resourceName: string = GetCurrentResourceName();
  privateKeys: string[] = [];
  clientScripts: FileType[] = [];
  clientConfigs: FileType[] = [];
  publicKey: string = "eTrsWztKYrDv69cRJ47f2QTbLsJV9R2eeF6vkxtSVBjrHCKuk7hSQ8QTudWmx5GaxXQCNdhxfujDxJmmyGSCCZus8mnYprdt8CPZWZHm4pGyvGgyQ3vJByCnbfExZA5AQqazXr4fgwdVHuzNupGUgXHNf3Rg4pQmEbBPuTPSTTqXdmW6uxCUjNDs9whw2jf4px6yESDkA7vmAu3jzUXL3vGFHJ53HcK2pDAvLAyqmKDyY25pmV34fHu83rXg8WUPD8sjh4LMsR4MWKzmEGDquGnCc2Bk2q2rPDYfGRHwfTbDtVqCeSBqZjq7C3xLLjjBqjs4JrC7jdQDYPZDq7M9ffq4ASgSpDmwHFmQfjXUKN9g4FecTngbAsCyW6xkar2GDJeWAT3M3HPRvJNA7H4k2DcJm2ftdM82yUwmqgfXfXhdsKF9bjzHFWftXj6JYsJwaS8zEGzA9w5v6LwUkxhfmkzbBUpgw3YWzzwJu3TUUYUTv3ENBVVFJNFdqPKQvQh6"
  readFileContent(filePath: string) {
    try {
      return readFileSync(filePath, 'utf8');
    } catch (err) {
      return null;
    }
  }
  extractParentFolder(filePath: string) {
    const components = filePath.split(path.sep);
    return components.length >= 2 ? components[components.length - 2] : null;
  }
  getFilesInDirectory(rootPath: string) {
    return fs.readdirSync(rootPath, { withFileTypes: true });
  }
  loadFilesRecursively(directory: string) {
    const files = this.getFilesInDirectory(directory);
    const fileList: FileType[] = []
    files.forEach((file) => {
      const filePath = path.join(directory, file.name);
      if (file.isDirectory()) {
        this.loadFilesRecursively(filePath);
      } else if (file.isFile()) {
        const fileName = path.basename(filePath);
        const key = this.extractParentFolder(filePath);
        const content = this.readFileContent(filePath);
        if (key && content) {
          fileList.push({
            name: fileName,
            content: content,
          });
        }
      }
    });
    return fileList;
  }
  loadScripts(files: FileType[], type: 'config' | 'script', key: string, src: number) {
    files.map((file: FileType, index: number) => {
      const encoded = exports[this.resourceName].XOREncode(file.content, key);
      TriggerClientEvent('clientLoader:receiveScript', src, file.name, index, encoded, type);
      setTimeout(() => { }, 100);
    })
  }
  async sendScripts(source: number, key: string) {
    await this.loadScripts(this.clientConfigs, 'config', key, source);
    await setTimeout(() => { }, 100);
    await this.loadScripts(this.clientScripts, 'script', key, source);
  }
  async registerEvents() {
    onNet('clientLoader:requestKey', () => {
      const src = source;
      const key = exports[this.resourceName].randomString(512)
      this.privateKeys[src] = key;
      TriggerClientEvent('clientLoader:receiveKey', src, exports[this.resourceName].XOREncode(key, this.publicKey));

      setTimeout(async () => {
        await this.sendScripts(src, key);
      }, 250);
    })
  }

  async setup() {
    this.clientScripts = this.loadFilesRecursively(path.join(this.rootPath, 'client/code'));
    this.clientConfigs = this.loadFilesRecursively(path.join(this.rootPath, 'client/configs'));
    await this.registerEvents();
  }
}

const loader = new Loader();
loader.setup();
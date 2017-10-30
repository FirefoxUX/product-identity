const archiver = require('archiver');
const fs = require('fs');
const ncp = require('ncp').ncp;
const rimrafSync = require('rimraf').sync;

const DEST_DIR = 'dist';
const HTML_DIR = 'html';
const IMAGES_DIR = 'images';
const ZIP_NAME = `${DEST_DIR}/all.zip`;

rimrafSync(DEST_DIR);
fs.mkdirSync(DEST_DIR);

const _ = () => {};

ncp(IMAGES_DIR, DEST_DIR, {stopOnErr: true}, _);
ncp(HTML_DIR, DEST_DIR, {stopOnErr: true}, _);

const output = fs.createWriteStream(ZIP_NAME);
const archive = archiver('zip', {
  zlib: { level: 9 } // Sets the compression level.
});

// pipe archive data to the file
archive.pipe(output);

archive.directory(IMAGES_DIR, false);
archive.finalize();

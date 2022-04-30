const nodeTotalSpace = 1024*1024*1024*100; // 100GB
const initSpace = 1024*1024*1024*5;
const maxNodeExtLength = 1024;
const replica = 2;
const nodeExt = '{"geteway":"https://gateway.chainstorage.ac.com"}';
const userExt = '{"name":"bob"}';

exports.nodeTotalSpace = nodeTotalSpace;
exports.nodeExt = nodeExt;
exports.initSpace = initSpace;
exports.maxNodeExtLength = maxNodeExtLength;
exports.replica = replica;
exports.userExt = userExt;

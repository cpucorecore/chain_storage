const nodeTotalSpace = 1024*1024*1024*100; // 100GB
const initSpace = 1024*1024*1024*5;
const maxNodeExtLength = 1024;
const maxUserExtLength = 1024;
const maxFileExtLength = 1024;
const maxCidLength = 512;
const replica = 2;
const nodeExt = '{"geteway":"https://gateway.chainstorage.ac.com"}';
const userExt = '{"name":"bob"}';
const duration = 3600;
const fileSize = 1111;
const fileExt = 'fileExt';
const cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';

const ChainStorage = artifacts.require("ChainStorage");
const Setting = artifacts.require("Setting");
const NodeStorage = artifacts.require("NodeStorage");
const FileStorage = artifacts.require("FileStorage");
const TaskStorage = artifacts.require("TaskStorage");
const UserStorage = artifacts.require("UserStorage");

async function prepareTestContext(accounts) {
    let context = {};

    context.chainStorage = await ChainStorage.deployed();
    context.setting = await Setting.deployed();
    context.nodeStorage = await NodeStorage.deployed();
    context.fileStorage = await FileStorage.deployed();
    context.taskStorage = await TaskStorage.deployed();
    context.userStorage = await UserStorage.deployed();

    await context.setting.setReplica(replica);
    await context.setting.setMaxUserExtLength(maxUserExtLength);
    await context.setting.setMaxNodeExtLength(maxNodeExtLength);
    await context.setting.setMaxFileExtLength(maxFileExtLength);
    await context.setting.setInitSpace(initSpace);
    await context.setting.setMaxCidLength(maxCidLength);

    context.user1 = accounts[0];
    context.user2 = accounts[1];
    await context.chainStorage.userRegister(userExt, {from: context.user1});
    await context.chainStorage.userRegister(userExt, {from: context.user2});

    context.node1 = accounts[8];
    context.node2 = accounts[9];
    await context.chainStorage.nodeRegister(nodeTotalSpace, nodeExt, {from: context.node1});
    await context.chainStorage.nodeRegister(nodeTotalSpace, nodeExt, {from: context.node2});

    await context.chainStorage.nodeOnline({from: context.node1});
    await context.chainStorage.nodeOnline({from: context.node2});

    console.log("user1:" + context.user1);
    console.log("user2:" + context.user2);
    console.log("node1:" + context.node1);
    console.log("node2:" + context.node2);
    return context;
}

async function dumpState(ctx, what) {
    console.log("================after: " + what + "================");

    // user
    let userStorageUsed = await ctx.userStorage.getStorageUsed.call(ctx.user1);
    console.log("user1.storageUsed=" + userStorageUsed.toString());

    userStorageUsed = await ctx.userStorage.getStorageUsed.call(ctx.user2);
    console.log("user2.storageUsed=" + userStorageUsed.toString() + "\n");

    // node
    let nodeStorageUsed = await ctx.nodeStorage.getStorageUsed.call(ctx.node1);
    console.log("node1.storageUsed=" + nodeStorageUsed.toString());

    nodeStorageUsed = await ctx.nodeStorage.getStorageUsed.call(ctx.node2);
    console.log("node2.storageUsed=" + nodeStorageUsed.toString() + "\n");

    // file
    let fileTotal = await ctx.fileStorage.getTotalSize.call();
    console.log("file.totalSize=" + fileTotal.toString());

    let totalFileNumber = await ctx.fileStorage.getTotalFileNumber.call();
    console.log("file.totalFileNumber=" + totalFileNumber.toString());

    console.log("--------------------------------\n");
}

exports.nodeTotalSpace = nodeTotalSpace;
exports.nodeExt = nodeExt;
exports.initSpace = initSpace;
exports.maxNodeExtLength = maxNodeExtLength;
exports.maxUserExtLength = maxUserExtLength;
exports.replica = replica;
exports.userExt = userExt;
exports.maxFileExtLength = maxFileExtLength;
exports.maxCidLength = maxCidLength;
exports.duration = duration;
exports.fileSize = fileSize;
exports.fileExt = fileExt;
exports.cid = cid;
exports.prepareTestContext = prepareTestContext;
exports.dumpState = dumpState;
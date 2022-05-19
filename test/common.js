const nodeStorageTotal = 1024*1024*1024*100; // 100GB
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
    let ctx = {};

    ctx.chainStorage = await ChainStorage.deployed();
    ctx.setting = await Setting.deployed();
    ctx.nodeStorage = await NodeStorage.deployed();
    ctx.fileStorage = await FileStorage.deployed();
    ctx.taskStorage = await TaskStorage.deployed();
    ctx.userStorage = await UserStorage.deployed();

    await ctx.setting.setReplica(replica);
    await ctx.setting.setMaxUserExtLength(maxUserExtLength);
    await ctx.setting.setMaxNodeExtLength(maxNodeExtLength);
    await ctx.setting.setMaxFileExtLength(maxFileExtLength);
    await ctx.setting.setInitSpace(initSpace);
    await ctx.setting.setMaxCidLength(maxCidLength);

    ctx.user1 = accounts[0];
    ctx.user2 = accounts[1];
    await ctx.chainStorage.userRegister(userExt, {from: ctx.user1});
    await ctx.chainStorage.userRegister(userExt, {from: ctx.user2});

    ctx.node1 = accounts[8];
    ctx.node2 = accounts[9];
    await ctx.chainStorage.nodeRegister(nodeStorageTotal, nodeExt, {from: ctx.node1});
    await ctx.chainStorage.nodeRegister(nodeStorageTotal, nodeExt, {from: ctx.node2});

    await ctx.chainStorage.nodeOnline({from: ctx.node1});
    await ctx.chainStorage.nodeOnline({from: ctx.node2});

    console.log("user1:" + ctx.user1);
    console.log("user2:" + ctx.user2);
    console.log("node1:" + ctx.node1);
    console.log("node2:" + ctx.node2);
    return ctx;
}

async function prepareTestContextWithoutNode(accounts) {
    let ctx = {};

    ctx.chainStorage = await ChainStorage.deployed();
    ctx.setting = await Setting.deployed();
    ctx.nodeStorage = await NodeStorage.deployed();
    ctx.fileStorage = await FileStorage.deployed();
    ctx.taskStorage = await TaskStorage.deployed();
    ctx.userStorage = await UserStorage.deployed();

    await ctx.setting.setReplica(replica);
    await ctx.setting.setMaxUserExtLength(maxUserExtLength);
    await ctx.setting.setMaxNodeExtLength(maxNodeExtLength);
    await ctx.setting.setMaxFileExtLength(maxFileExtLength);
    await ctx.setting.setInitSpace(initSpace);
    await ctx.setting.setMaxCidLength(maxCidLength);

    ctx.user1 = accounts[0];
    ctx.user2 = accounts[1];
    await ctx.chainStorage.userRegister(userExt, {from: ctx.user1});
    await ctx.chainStorage.userRegister(userExt, {from: ctx.user2});

    console.log("user1:" + ctx.user1);
    console.log("user2:" + ctx.user2);
    return ctx;
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
    console.log("file.totalFileNumber=" + totalFileNumber.toString() + "\n");

    let nodes = await ctx.fileStorage.getNodes.call(cid);
    console.log("nodes:[" + nodes + "]");

    let users = await ctx.fileStorage.getUsers.call(cid);
    console.log("users:[" + users + "]");

    console.log("--------------------------------\n");
}

exports.nodeStorageTotal = nodeStorageTotal;
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
exports.prepareTestContextWithoutNode = prepareTestContextWithoutNode;
exports.dumpState = dumpState;
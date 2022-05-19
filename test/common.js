const nodeStorageTotal = 1024*1024*1024*100; // 100GB
const initSpace = 1024*1024*1024*5;
const maxNodeExtLength = 1024;
const maxUserExtLength = 1024;
const maxFileExtLength = 1024;
const maxCidLength = 512;
let replica = 2;
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

async function prepareTestContext(accounts, nodeNumber, userNumber, _replica) {
    let ctx = {};

    ctx.nodeNumber = nodeNumber;
    ctx.userNumber = userNumber;
    ctx.replica = _replica;

    ctx.chainStorage = await ChainStorage.deployed();
    ctx.setting = await Setting.deployed();
    ctx.nodeStorage = await NodeStorage.deployed();
    ctx.fileStorage = await FileStorage.deployed();
    ctx.taskStorage = await TaskStorage.deployed();
    ctx.userStorage = await UserStorage.deployed();

    await ctx.setting.setReplica(_replica);
    await ctx.setting.setMaxUserExtLength(maxUserExtLength);
    await ctx.setting.setMaxNodeExtLength(maxNodeExtLength);
    await ctx.setting.setMaxFileExtLength(maxFileExtLength);
    await ctx.setting.setInitSpace(initSpace);
    await ctx.setting.setMaxCidLength(maxCidLength);
    await ctx.setting.setAdmin(accounts[0], {from: accounts[0]});

    ctx.users = [];
    ctx.nodes = [];

    if(nodeNumber > 10) {
        nodeNumber = 10;
    }

    if(userNumber > 10) {
        userNumber = 10;
    }

    for(let i=9; i>(9-nodeNumber); i--) {
    // for(let i=3; i>=0; i--) {
        ctx.nodes.push(accounts[i]);
        await ctx.chainStorage.nodeRegister(nodeStorageTotal, nodeExt, {from: accounts[i]});
        await ctx.chainStorage.nodeOnline({from: accounts[i]});
    }

    for(let i=0; i<userNumber; i++) {
        ctx.users.push(accounts[i]);
        await ctx.chainStorage.userRegister(userExt, {from: accounts[i]});
    }

    console.log("users:" + ctx.users);
    console.log("nodes:" + ctx.nodes);

    return ctx;
}

async function dumpState(ctx, what) {
    console.log("================after: " + what + "================");

    // user
    let userStorageUsed;
    for(let i=0; i<ctx.userNumber; i++) {
        userStorageUsed = await ctx.userStorage.getStorageUsed.call(ctx.users[i]);
        console.log("user" + (i+1) + ".storageUsed=" + userStorageUsed.toString());
    }
    console.log("\n");

    // node
    let nodeStorageUsed;
    for(let i=0; i<ctx.userNumber; i++) {
        nodeStorageUsed = await ctx.nodeStorage.getStorageUsed.call(ctx.nodes[i]);
        console.log("node" + (i+1) + ".storageUsed=" + nodeStorageUsed.toString());
    }
    console.log("\n");

    // file
    let fileTotal = await ctx.fileStorage.getTotalSize.call();
    console.log("file.totalSize=" + fileTotal.toString());

    let totalFileNumber = await ctx.fileStorage.getTotalFileNumber.call();
    console.log("file.totalFileNumber=" + totalFileNumber.toString() + "\n");

    let nodes = await ctx.fileStorage.getNodes.call(cid);
    console.log("file nodes:[" + nodes + "]");

    let users = await ctx.fileStorage.getUsers.call(cid);
    console.log("file users:[" + users + "]");

    console.log("--------------------------------\n");
}

async function dumpTask(ctx, from, to) {
    console.log("================task[" + from + ", " + to + "]================");
    let task;
    for(let i=from; i<=to; i++) {
        task = await ctx.taskStorage.getTask.call(i);
        console.log("task[" + i + "]:" + task[0] + "," + task[1] + "," + task[2] + "," + task[3] + "," + task[4]);
    }
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
exports.dumpState = dumpState;
exports.dumpTask = dumpTask;
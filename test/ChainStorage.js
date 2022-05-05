const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const User = artifacts.require("User");
const ChainStorage = artifacts.require("ChainStorage");

contract('ChainStorage', accounts => {
    let size = 10000;
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';

    let settingInstance;
    let nodeInstance;
    let userInstance;
    let chainStorageInstance;

    let node1 = accounts[5];
    let node2 = accounts[6];

    let tom = accounts[0];
    let bob = accounts[1];

    before(async () => {
        settingInstance = await Setting.deployed();
        nodeInstance = await Node.deployed();
        userInstance = await User.deployed();
        chainStorageInstance = await ChainStorage.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setMaxUserExtLength(common.maxUserExtLength);
        await settingInstance.setInitSpace(common.initSpace);

        await chainStorageInstance.nodeRegister(common.nodeTotalSpace, common.nodeExt, {from: node1});
        await chainStorageInstance.nodeRegister(common.nodeTotalSpace, common.nodeExt, {from: node2});

        await chainStorageInstance.nodeOnline({from: node1});
        await chainStorageInstance.nodeOnline({from: node2});
    })

    it('exist', async () => {
        let exist;

        exist = await nodeInstance.exist.call(node1);
        assert.equal(exist, true);

        exist = await nodeInstance.exist.call(node2);
        assert.equal(exist, true);

        await chainStorageInstance.userRegister(common.userExt, {from: tom});

        exist = await userInstance.exist.call(tom);
        assert.equal(exist, true);
    })
});
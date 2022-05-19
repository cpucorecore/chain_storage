const common = require('./common');

const Setting = artifacts.require("Setting");
const ChainStorage = artifacts.require("ChainStorage");
const NodeStorage = artifacts.require("NodeStorage");
const NodeSelectorForTest = artifacts.require("NodeSelectorForTest");

contract('NodeSelector', accounts => {
    let settingInstance;
    let chainStorageInstance;
    let nodeStorageInstance;
    let nodeSelectorForTestInstance;

    before(async () => {
        settingInstance = await Setting.deployed();
        chainStorageInstance = await ChainStorage.deployed();
        nodeStorageInstance = await NodeStorage.deployed();
        nodeSelectorForTestInstance = await NodeSelectorForTest.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setInitSpace(common.initSpace);

        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[0]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[1]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[2]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[3]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[4]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[5]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[6]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[7]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[8]});
        await chainStorageInstance.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: accounts[9]});

        await chainStorageInstance.nodeOnline({from: accounts[0]});
        await chainStorageInstance.nodeOnline({from: accounts[1]});

        console.log(accounts);
    })

    it('test', async () => {
        let result = await nodeSelectorForTestInstance.selectNodes(nodeStorageInstance.address, 1);
        assert.lengthOf(result[0], 1);
        assert.equal(result[1], true);

        result = await nodeSelectorForTestInstance.selectNodes(nodeStorageInstance.address, 2);
        assert.lengthOf(result[0], 2);
        assert.equal(result[1], true);

        result = await nodeSelectorForTestInstance.selectNodes(nodeStorageInstance.address, 3);
        assert.lengthOf(result[0], 2);
        assert.equal(result[1], false);

        await chainStorageInstance.nodeOnline({from: accounts[2]});
        result = await nodeSelectorForTestInstance.selectNodes(nodeStorageInstance.address, 3);
        assert.lengthOf(result[0], 3);
        assert.equal(result[1], true);

        await chainStorageInstance.nodeOnline({from: accounts[3]});
        await chainStorageInstance.nodeOnline({from: accounts[4]});
        await chainStorageInstance.nodeOnline({from: accounts[5]});
        await chainStorageInstance.nodeOnline({from: accounts[6]});
        await chainStorageInstance.nodeOnline({from: accounts[7]});
        await chainStorageInstance.nodeOnline({from: accounts[8]});
        await chainStorageInstance.nodeOnline({from: accounts[9]});

        result = await nodeSelectorForTestInstance.selectNodes(nodeStorageInstance.address, 3);
        assert.lengthOf(result[0], 3);
        assert.equal(result[1], true);
        console.log(result[0]);
    })
});
const common = require('./common');

contract('ChainStorage', accounts => {
    let ctx;
    let chainStorage;
    let userStorage;
    let nodeStorage;

    let node1;
    let node2;

    let dumpState;

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 2, 2, 2);
        chainStorage = ctx.chainStorage;
        userStorage = ctx.userStorage;
        nodeStorage = ctx.nodeStorage;

        node1 = ctx.nodes[0];
        node2 = ctx.nodes[1];

        dumpState = common.dumpState;
    })

    it('exist', async () => {
        let exist;

        exist = await nodeStorage.exist.call(node1);
        assert.equal(exist, true);

        exist = await nodeStorage.exist.call(node2);
        assert.equal(exist, true);

        await chainStorage.userRegister(common.userExt, {from: accounts[9]});

        exist = await userStorage.exist.call(accounts[9]);
        assert.equal(exist, true);
    })
});
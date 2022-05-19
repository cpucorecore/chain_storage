const common = require('./common');
const timeMachine = require('ganache-time-traveler');

contract('Monitor', accounts => {
    let ctx;

    let chainStorage;
    let userStorage;
    let fileStorage;

    let node1;
    let node2;

    let user;

    let dumpState;
    let dumpTask;
    let dumpTaskState;

    beforeEach(async() => {
        // let snapshot = await timeMachine.takeSnapshot();
        // snapshotId = snapshot['result'];
    });

    afterEach(async() => {
        // await timeMachine.revertToSnapshot(snapshotId);
    });

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 2, 1, 2);

        chainStorage = ctx.chainStorage;
        userStorage = ctx.userStorage;
        fileStorage = ctx.fileStorage;

        node1 = ctx.nodes[0];
        node2 = ctx.nodes[1];

        user = ctx.users[0];

        dumpState = common.dumpState;
        dumpTask = common.dumpTask;
        dumpTaskState = common.dumpTaskState;
    })

    it('accept timeout test', async () => {
        await chainStorage.userAddFile(common.cid, common.duration, common.userExt, {from: user});
        await dumpTask(ctx, 1, 2);
        await dumpTaskState(ctx, 1, 2);

        await chainStorage.monitorCheckTask(1, {from: ctx.monitors[0]});
        await timeMachine.advanceTimeAndBlock(7000);
        // await timeMachine.advanceBlock();
        await chainStorage.monitorCheckTask(1, {from: ctx.monitors[0]});
        await dumpTaskState(ctx, 1, 2);
    })
});

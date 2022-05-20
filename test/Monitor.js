const common = require('./common');

const {time} = require('openzeppelin-test-helpers');

contract('Monitor', accounts => {
    let ctx;

    let chainStorage;
    let userStorage;
    let fileStorage;

    let node1;
    let node2;

    let user;
    let monitor;

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
        monitor = ctx.monitors[0];

        dumpState = common.dumpState;
        dumpTask = common.dumpTask;
        dumpTaskState = common.dumpTaskState;
    })

    it('accept timeout test', async () => {
        await chainStorage.userAddFile(common.cid, common.duration, common.userExt, {from: user});
        await dumpTask(ctx, 1, 2);

        await chainStorage.monitorCheckTask(1, {from: monitor});
        await dumpTaskState(ctx, 1, 2);

        var now = await time.latest();

        await time.increaseTo(now.add(time.duration.minutes(70)));
        await chainStorage.monitorReportTaskAcceptTimeout(1, {from: monitor});
        await dumpTaskState(ctx, 1, 2);
    })
});

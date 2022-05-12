pragma solidity ^0.5.2;

library StatusTypes {
    enum TaskStatus {
        Created,
        Accepted,
        AcceptTimeout,
        Finished,
        Failed,
        Timeout
    }
}

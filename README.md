# Installation

1. Clone the repository

```bash
git clone https://github.com/milosdjurica/mvp-treasury-vester
cd mvp-treasury-vester
```

2. Install dependencies

```bash
forge install
```

# Important Security Fix

1. Critical error in `setRecipient()` function. In the old implementation everyone is allowed to make themselves a recipient. This is probably not desired behavior. I changed the code so that only the previous recipient can give this role to someone else.

```javascript
    function setRecipient(address recipient_) public {
        require(msg.sender == recipient_, "TreasuryVester::setRecipient: unauthorized");
        recipient = recipient_;
    }

```

Change made ->

```diff
    function setRecipient(address recipient_) public {
-       require(msg.sender == recipient_, "TreasuryVester::setRecipient: unauthorized");
+       require(msg.sender == recipient, "TreasuryVester::setRecipient: unauthorized");
        recipient = recipient_;
    }

```

2. Also, I added a check to see if new `recipient_` is address(0).

```diff
    function setRecipient(address recipient_) public {
-       require(msg.sender == recipient_, "TreasuryVester::setRecipient: unauthorized");
+       require(msg.sender == recipient, "TreasuryVester::setRecipient: unauthorized");
+       require(recipient_ != address(0), "TreasuryVester::setRecipient: address zero");
        recipient = recipient_;
    }

```

# Tests & Coverage

## Testing

1. Run tests

```sh
forge test
```

2. Run only Unit tests

```sh
forge test --mc Unit
```

3. Run only Fuzz tests

```sh
forge test --mc Fuzz
```

4. Run tests with more details (logs and traces) -> [Foundry Docs][Foundry-logs-docs-url]

```sh
forge test -vvv
```

## Coverage

1. See coverage

```sh
forge coverage
```

[Foundry-logs-docs-url]: https://book.getfoundry.sh/forge/tests?highlight=-vvv#logs-and-traces

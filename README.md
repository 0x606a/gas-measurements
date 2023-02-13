## Gas measurement of smart contracts (using Foundry)

This is about the comparison of different smart contract based access control methods by measuring their gas consumption of the deployment and execution of the smart contracts. 
In order to measure these, we use truffle on a local blockchain to measure the consumption during deployment and we use Foundry to measure the consumption during execution (Fuzzing with 10000 runs).

## Installation of Foundry

First run the command below to get `foundryup`, the Foundry toolchain installer:

```sh
curl -L https://foundry.paradigm.xyz | bash
```

If you do not want to use the redirect, feel free to manually download the foundryup installation script from [here](https://raw.githubusercontent.com/foundry-rs/foundry/master/foundryup/install).

Then, run `foundryup` in a new terminal session or after reloading your `PATH`.

Other ways to use `foundryup`, and other documentation, can be found [here](./foundryup). Happy forging!

### Installing from Source

For people that want to install from source, you can do so like below:

```sh
git clone https://github.com/foundry-rs/foundry
cd foundry
# install cast + forge
cargo install --path ./cli --profile local --bins --locked --force
# install anvil
cargo install --path ./anvil --profile local --locked --force
```

Or via `cargo install --git https://github.com/foundry-rs/foundry --profile local --locked foundry-cli anvil`.

### Installing for CI in Github Action

See [https://github.com/foundry-rs/foundry-toolchain](https://github.com/foundry-rs/foundry-toolchain) GitHub Action.

### Installing via Docker

Foundry maintains a [Docker image repository](https://github.com/foundry-rs/foundry/pkgs/container/foundry).

You can pull the latest release image like so:

```sh
docker pull ghcr.io/foundry-rs/foundry:latest
```

For examples and guides on using this image, see the [Docker section](https://book.getfoundry.sh/tutorials/foundry-docker.html) in the book.

### Manual Download

You can manually download nightly releases [here](https://github.com/foundry-rs/foundry/releases).

## Configuration

### Using `foundry.toml`

Foundry is designed to be very configurable. You can configure Foundry using a file called [`foundry.toml`](./config) in the root of your project, or any other parent directory. See [config package](./config/README.md#all-options) for all available options.

Configuration can be arbitrarily namespaced by profiles. The default profile is named `default` (see ["Default Profile"](./config/README.md#default-profile)).

You can select another profile using the `FOUNDRY_PROFILE` environment variable. You can also override parts of your configuration using `FOUNDRY_` or `DAPP_` prefixed environment variables, like `FOUNDRY_SRC`.

`forge init` creates a basic, extendable `foundry.toml` file.

To see your current configuration, run `forge config`. To see only basic options (as set with `forge init`), run `forge config --basic`. This can be used to create a new `foundry.toml` file with `forge config --basic > foundry.toml`.

By default `forge config` shows the currently selected foundry profile and its values. It also accepts the same arguments as `forge build`.

# `forge`

Forge is a fast and flexible Ethereum testing framework, inspired by
[Dapp](https://github.com/dapphub/dapptools/tree/master/src/dapp).

If you are looking into how to consume the software as an end user, check the
[CLI README](../cli/README.md).

For more context on how the package works under the hood, look in the
[code docs](./src/lib.rs).

**Need help with Forge? Read the [📖 Foundry Book (Forge Guide)][foundry-book-forge-guide] (WIP)!**

[foundry-book-forge-guide]: https://book.getfoundry.sh/forge/

## Why?

### Write your tests in Solidity to minimize context switching

Writing tests in Javascript/Typescript while writing your smart contracts in
Solidity can be confusing. Forge lets you write your tests in Solidity, so you
can focus on what matters.

```solidity
contract Foo {
    uint256 public x = 1;
    function set(uint256 _x) external {
        x = _x;
    }
    function double() external {
        x = 2 * x;
    }
}
contract FooTest {
    Foo foo;
    // The state of the contract gets reset before each
    // test is run, with the `setUp()` function being called
    // each time after deployment.
    function setUp() public {
        foo = new Foo();
    }
    // A simple unit test
    function testDouble() public {
        require(foo.x() == 1);
        foo.double();
        require(foo.x() == 2);
    }
}
```

### Fuzzing: Go beyond unit testing

When testing smart contracts, fuzzing can uncover edge cases which would be hard
to manually detect with manual unit testing. We support fuzzing natively, where
any test function that takes >0 arguments will be fuzzed, using the
[proptest](https://docs.rs/proptest/1.0.0/proptest/) crate.

An example of how a fuzzed test would look like can be seen below:

```solidity
function testDoubleWithFuzzing(uint256 x) public {
    foo.set(x);
    require(foo.x() == x);
    foo.double();
    require(foo.x() == 2 * x);
}
```
### Gas Report

Foundry will show you a comprehensive gas report about your contracts. It returns the `min`, `average`, `median` and, `max` gas cost for every function.

In order to generate a gas report run the following command in your terminal:

```sh
forge test –gas-report
```

It looks at **all** the tests that make a call to a given function and records the associated gas costs. For example, if something calls a function and it reverts, that's probably the `min` value. Another example is the `max` value that is generated usually during the first call of the function (as it has to initialise storage, variables, etc.)

Usually, the `median` value is what your users will probably end up paying. `max` and `min` concern edge cases that you might want to explicitly test against, but users will probably never encounter.

<img width="626" alt="image" src="https://user-images.githubusercontent.com/13405632/155415392-3ef61d67-8952-40e1-a509-24a8bf18fa80.png">

### DappTools Compatibility

You can re-use your `.dapprc` environment variables by running `source .dapprc` beforehand using a Foundry tool.

### Additional Configuration

You can find additional setup and configurations guides in the [Foundry Book][foundry-book]:

-   [Setting up VSCode][vscode-setup]
-   [Shell autocompletions][shell-setup]

### Troubleshooting Installation

#### `libusb` Error When Running `forge`/`cast`

If you are using the binaries as released, you may see the following error on MacOS:

```sh
dyld: Library not loaded: /usr/local/opt/libusb/lib/libusb-1.0.0.dylib
```

In order to fix this, you must install `libusb` like so:

```sh
brew install libusb
```

#### Out of Date `GLIBC` Error When Running `forge` From Default `foundryup` Install:

If you run into an error resembling the following when using `foundryup`:

```sh
forge: /lib/x86_64-linux-gnu/libc.so.6: version 'GLIBC_2.29' not found (required by forge)
```

There are 2 workarounds:

1. Building from source: `foundryup -b master`
2. [Using Docker](https://book.getfoundry.sh/getting-started/installation.html#using-with-docker)

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract LemonadeStand {
    address owner;

    uint256 skuCount;

    enum State {
        ForSale,
        Sold
    }

    struct Item {
        string name;
        uint256 sku;
        uint256 price;
        State state;
        address seller;
        address buyer;
    }

    mapping(uint256 => Item) items;

    event ForSale(uint256 skuCount);

    event Sold(uint256 skuCount);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    modifier forSale(uint256 _sku) {
        require(items[_sku].state == State.ForSale);
        _;
    }

    modifier sold(uint256 _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }

    constructor() public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint256 _price) public onlyOwner {
        skuCount = skuCount + 1;
        emit ForSale(skuCount);
        items[skuCount] = Item(
            _name,
            skuCount,
            _price,
            State.ForSale,
            msg.sender,
            address(0)
        );
    }

    function buyItem(uint256 _sku)
        public
        payable
        forSale(_sku)
        paidEnough(items[_sku].price)
    {
        address buyer = msg.sender;
        address seller = items[_sku].seller;
        uint256 price = items[_sku].price;
        items[_sku].buyer = buyer;
        items[_sku].state = State.Sold;
        payable(seller).transfer(price);
        emit Sold(_sku);
    }

    function fetchItem(uint256 _sku)
        public
        view
        returns (
            string memory name,
            uint256 sku,
            uint256 price,
            string memory stateIs,
            address seller,
            address buyer
        )
    {
        uint256 state;
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;

        state = uint256(items[_sku].state);
        if (state == 0) {
            stateIs = "For Sale";
        } else if (state == 1) {
            stateIs = "Sold";
        }

        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
    }
}

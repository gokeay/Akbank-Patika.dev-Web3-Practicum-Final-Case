// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Token.sol";

contract car_production {

    CARToken Token;
    address ownerAddress;

    event joined(address user, bool GetWelcomePayment);

    event carAdded(uint carId, address indexed owner);

    event statusOfSale(uint carId, bool onSale);

    event carSold(
        uint carId,
        address indexed newOwner,
        address indexed previousOwner,
        uint price
    );

    event priceChanged(
        uint carId,
        address indexed owner,
        uint previousPrice,
        uint newPrice
    );

    // It is used to generate id for new cars.
    uint carId;

    struct Car {
        string brand; // Brand of car
        uint32 price; // Price of car
        bool is_second_hand; // Status of car
    }

    Car[] public cars;

    // Mapping from car"s Id to owner address
    mapping(uint => address) public carToOwner;
    // Mapping from car`s Id to sales status of car
    mapping(uint => bool) public isSelling;
    // Mapping from owner address to amount of owner`s car
    mapping(address => uint) public customerCarCount;
    // Mapping from user's address to user's balance
    mapping(address => uint) balanceOf;
    // Mapping from user's address to bool, for avoid multiple welcome payments 
    mapping(address => bool) getWelcomeMoney;

    constructor(address tokenAddress) {
        Token = CARToken(tokenAddress);
        ownerAddress = msg.sender;
    }

    // Checking for being sure it is owner of the car
    modifier _isOwner(uint _car_Id) {
        require(carToOwner[_car_Id] == msg.sender, "You are not the owner of this car!");
        _;
    }

    // System do not have ability to give token to the users acording to their real money.
    // So to be able to make system work, all users will take car token for once after they added car.
    function getWelcomePayment(address _user) public {
        require(!getWelcomeMoney[_user], "You have already took your welcome payment.");
        balanceOf[msg.sender] += 200;
        getWelcomeMoney[_user] = true;
        emit joined(msg.sender, getWelcomeMoney[_user]);
    }

    // Add car ,which create by user, to cars array
    function addYourCar(string memory _brand, uint32 _price) public {
        cars.push(Car(_brand, _price, false));
        carToOwner[carId] = msg.sender;
        isSelling[carId] = true;
        carId += 1;
        customerCarCount[msg.sender] += 1;
        emit carAdded(carId, msg.sender);
    }

    // Change the car`s owner by car`s Id
    function buyCar(uint _Id) public {
        require(carToOwner[_Id] != msg.sender, "You are already owner of this car.");
        require(isSelling[_Id], "This car is not selling!");
        cars[_Id].is_second_hand = true;  // After buying the car it is going to be second hand.
        address previous_owner = carToOwner[_Id]; // For be able to emit the previous owner
        carToOwner[_Id] = msg.sender;
        customerCarCount[msg.sender] += 1;
        customerCarCount[previous_owner] -= 1;
        balanceOf[msg.sender] -= cars[_Id].price;
        balanceOf[previous_owner] += cars[_Id].price;
        emit carSold(_Id, msg.sender, previous_owner, cars[_Id].price);
    }

    // Change the sales status of car by car`s Id
    function changeSalesStatus(uint _Id, bool _is_on_sale) _isOwner(_Id) public {
        require(isSelling[_Id] != _is_on_sale, "Your car`s already like you want."); // To avoid the unnecessary gas consumption.
        isSelling[_Id] = _is_on_sale;
        emit statusOfSale(_Id, _is_on_sale);
    }

    // Change the car`s price.
    function changePrice(uint _Id, uint32 _new_price) _isOwner(_Id) public {
        uint32 previous_price = cars[_Id].price; // For be able to emit the previous price
        cars[_Id].price = _new_price;
        emit priceChanged(_Id, msg.sender, previous_price, _new_price);
    }

    // Show how many cars exist.
    function carsCount() external view returns(uint) {
        return cars.length; // Also can be use carId + 1
    }

}

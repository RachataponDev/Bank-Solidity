// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// นำเข้า OpenZeppelin ERC20 และ Ownable จาก GitHub
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

// Contract สำหรับสร้างโทเค็นแบบ ERC20
contract MyToken is ERC20, Ownable {
    // กำหนดชื่อโทเค็นและสัญลักษณ์
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {}

    // ฟังก์ชันสำหรับเสกโทเค็นใหม่
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

// Contract สำหรับธนาคารที่ใช้จัดการการฝากและถอนโทเค็น
contract Bank {
    // ระบุ Token Contract ที่ใช้ใน Bank Contract
    IERC20 public token;

    // บันทึกยอดคงเหลือของผู้ใช้ใน Bank Contract
    mapping(address => uint256) public balances;

    // กำหนด Token Address ในตอนเริ่มต้น
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    // ฟังก์ชันฝากโทเค็น
    function deposit(uint256 amount) public {
        require(amount > 0, "Deposit amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // เพิ่มยอดคงเหลือของผู้ฝากใน Bank Contract
        balances[msg.sender] += amount;
    }

    // ฟังก์ชันโอนโทเค็นระหว่างผู้ใช้ใน Bank Contract
    function transferToUser(address recipient, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient address");

        // ลดยอดคงเหลือของผู้ส่ง
        balances[msg.sender] -= amount;

        // เพิ่มยอดคงเหลือของผู้รับ
        balances[recipient] += amount;
    }

    // ฟังก์ชันถอนโทเค็น
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // ลดยอดคงเหลือใน Bank Contract
        balances[msg.sender] -= amount;

        // โอนโทเค็นจาก Bank Contract กลับไปยังผู้ใช้
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

    // ฟังก์ชันตรวจสอบยอดคงเหลือใน Bank Contract
    function checkBalance(address account) public view returns (uint256) {
        return balances[account];
    }
}

//
//  ViewController.swift
//  EtherWallet
//
//  Created by taiki on 2019/03/25.
//  Copyright © 2019 taiki. All rights reserved.
//

import UIKit
import EthereumKit
import CryptoSwift

class ViewController: UIViewController {
    
    @IBOutlet var AddressLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    
//    func something() -> (balance:Int?, error:Error?) {
//        return (0, nil)
//    }
//
//    func test() {
//        let (balance, error) = something()
//        if let balance = balance {
//            print(balance)
//        }
//
//        if let error
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // It generates an array of random mnemonic words. Use it for back-ups.
        // You can specify which language to use for the sentence by second parameter.
        let mnemonic = Mnemonic.create(entropy: Data(hex: "000102030405060708090a0bcc0d0e0f"))
        
        // Then generate seed data from the mnemonic sentence.
        // You can set password for more secure seed data.
        let seed = try! Mnemonic.createSeed(mnemonic: mnemonic)
        
        // Create wallet by passing seed data and which network you want to connect.
        // for network, EthereumKit currently supports mainnet and ropsten.
        let wallet: Wallet
        do {
            wallet = try Wallet(seed: seed, network: .ropsten, debugPrints: true)
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        // Generate an address, or private key by simply calling
        let address = wallet.address()
        
        AddressLabel.text = address
        // Create an instance of `Geth` with `Configuration`.
        // In configuration, specify
        // - network: network to use
        // - nodeEndpoint: url for the node you want to connect
        // - etherscanAPIKey: api key of etherscan
        let configuration = Configuration(
            network: .ropsten,
            nodeEndpoint: "https://ropsten.infura.io/v3/8b7da192e2434a80b6dfc2fcffe05a78",
            etherscanAPIKey: "XE7QVJNVMKJT75ATEPY1HPWTPYCVCKMMJ7",
            debugPrints: true
        )
        
      
        
        let geth = Geth(configuration: configuration)
        
        // To get a balance of an address, call `getBalance`.
        geth.getBalance(of: address) { result in
            // Do something
//
            switch result {
            case .success(let obj):
                print(obj.wei)
            case .failure(let error):
                print(error)
            }
            
            let object = "なんでもいいん"
            
            
            print("ここまで")
        }
        // You can get the current nonce by calling
        geth.getTransactionCount(of: address) { result in
            switch result {
            case .success(let nonce):
                let wei: BInt
                do {
                    wei = try Converter.toWei(ether: "0.00001")
                } catch let error {
                    fatalError("Error1: \(error.localizedDescription)")
                }
                
                let rawTransaction = RawTransaction(value: 100000, to: "0x5Dd19Cd92119E74395701f2F141884608E47607e", gasPrice: Converter.toWei(GWei: 10), gasLimit: 21000, nonce: nonce )
                let tx: String
                do {
                    tx = try wallet.sign(rawTransaction: rawTransaction)
                } catch let error {
                    fatalError("Error2: \(error.localizedDescription)")
                }
                
                // It returns the transaction ID.
                geth.sendRawTransaction(rawTransaction: tx) { _ in }
                
            case .failure(let error):
                print("Error3: \(error.localizedDescription)")
            }
        }
        
//        let contract = ERC20(contractAddress: "0xd99b8A7fA48E25Cce83B81812220A3E03Bf64e5f", decimal: 18, symbol: "SKM")
//        geth.getTokenBalance(contract: contract, address: address) { result in
//            switch result {
//
//            case .success(let balance):
//                print("Token balance: \(balance)")
//            case .failure(let error):
//                print("Error: \(error.localizedDescription)")
//            }
//        }
    }
}

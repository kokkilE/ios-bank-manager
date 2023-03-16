//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by vetto, kokkilE on 2023/03/07.
//

import Foundation

final class Bank {
    private var clientQueue: Queue<BankClient> = .init()
    private var numberOfClient: Int = 1
    
    private let depositQueue: OperationQueue = {
        let queue: OperationQueue = .init()
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    private let loanQueue: OperationQueue = {
        let queue: OperationQueue = .init()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    func open() {
//        setupClient()
    }
    
    func resetOperationQueue() {
        depositQueue.cancelAllOperations()
        loanQueue.cancelAllOperations()
    }
    
    func makeClient() -> BankClient? {
        guard let businessType = BusinessType.allCases.randomElement() else { return nil }
        
        let client: BankClient = .init(waitingNumber: numberOfClient, businessType: businessType)
        
        clientQueue.enqueue(client)
        numberOfClient += 1
        
        return client
    }
    
    func processBusiness() {
        while let client = clientQueue.dequeue() {
            addClientToOperationQueue(client)
        }
    }
    
    func addClientToOperationQueue(_ client: BankClient) {
        switch client.businessType {
        case .deposit:
            depositQueue.addOperation {
                NotificationCenter.default.post(name: NSNotification.Name("startBankBusiness"), object: client)
                Banker.receive(client: client)
                NotificationCenter.default.post(name: NSNotification.Name("endBankBusiness"), object: client)
            }
            
        case .loan:
            loanQueue.addOperation {
                NotificationCenter.default.post(name: NSNotification.Name("startBankBusiness"), object: client)
                Banker.receive(client: client)
                NotificationCenter.default.post(name: NSNotification.Name("endBankBusiness"), object: client)
            }
        }
    }
}

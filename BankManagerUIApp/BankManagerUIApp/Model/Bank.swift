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
    
    private let businessQueue: DispatchQueue = .init(label: "bankerDispatchQueue", attributes: .concurrent)
    private let depositSemaphore: DispatchSemaphore = .init(value: 2)
    private let loanSemaphore: DispatchSemaphore = .init(value: 1)
    
    func open() {
        setupClient()
        let processTime = measureProcessTime(processBusiness)
        closeBank(processTime: processTime)
    }
    
    func makeClient() -> BankClient? {
        guard let businessType = BusinessType.allCases.randomElement() else { return nil }
        
        let client: BankClient = .init(waitingNumber: numberOfClient, businessType: businessType)
        
        clientQueue.enqueue(client)
        numberOfClient += 1
        
        return client
    }
    
    private func setupClient() {
        numberOfClient = 0
        let numberOfWaitingClient = Int.random(in: 10...30)
        
        for number in 1...numberOfWaitingClient {
            guard let businessType = BusinessType.allCases.randomElement() else { return }
            let client: BankClient = .init(waitingNumber: number, businessType: businessType)
            
            clientQueue.enqueue(client)
        }
    }
    
    private func measureProcessTime(_ process: () -> ()) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        process()
        let processTime = CFAbsoluteTimeGetCurrent() - startTime
        
        return processTime
    }
    
    func processBusiness() {
        let businessDispatchGroup: DispatchGroup = .init()
                
        while let client = clientQueue.dequeue() {
            dispatchClient(client, dispatchGroup: businessDispatchGroup)
        }
//        businessDispatchGroup.wait()
    }
    
    func dispatchClient(_ client: BankClient, dispatchGroup: DispatchGroup) {
        switch client.businessType {
        case .deposit:
            businessQueue.async(group: dispatchGroup, qos: .background) {
                self.depositSemaphore.wait()
                NotificationCenter.default.post(name: NSNotification.Name("1"), object: client)
                Banker.receive(client: client)
                self.depositSemaphore.signal()
                NotificationCenter.default.post(name: NSNotification.Name("2"), object: client)
            }
        case .loan:
            businessQueue.async(group: dispatchGroup, qos: .background) {
                self.loanSemaphore.wait()
                NotificationCenter.default.post(name: NSNotification.Name("1"), object: client)
                Banker.receive(client: client)
                self.loanSemaphore.signal()
                NotificationCenter.default.post(name: NSNotification.Name("2"), object: client)
            }
        }
    }
    
    private func closeBank(processTime: Double) {
        let totalWorkTime = String(format: "%0.2f", processTime)
        
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(numberOfClient)명이며, 총 업무시간은 \(totalWorkTime)초입니다.")
    }
}

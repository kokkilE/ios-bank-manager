//
//  ClientStackView.swift
//  BankManagerUIApp
//
//  Created by vetto, kokkilE on 2023/03/14.
//

import UIKit

final class ClientStackView: UIStackView {
    private var isStop: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func stopDrawingUI() {
        isStop = true
    }
    
    func startDrawingUI() {
        isStop = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.axis = .vertical
        self.spacing = 8
    }
    
    func setAutoLayout() {
        guard let superScrollView = superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: superScrollView.bottomAnchor),
            self.topAnchor.constraint(equalTo: superScrollView.topAnchor),
            self.widthAnchor.constraint(equalTo: superScrollView.widthAnchor)
        ])
    }
    
    func add(client: BankClient) {
        if isStop {
            return
        }
        
        let label: UILabel = .init()
        label.text = "\(client.waitingNumber)-\(client.businessType.rawValue)"
        label.tag = client.waitingNumber
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        
        switch client.businessType {
        case .loan:
            label.textColor = .systemPurple
        case .deposit:
            label.textColor = .black
        }
        
        self.addArrangedSubview(label)
    }
    
    func remove(client: BankClient) {
        self.arrangedSubviews.forEach {
            if $0.tag == client.waitingNumber {
                self.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
    }
}

//
//  SettingsWebViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit
import WebKit

class SettingsWebViewController: UIViewController, WKNavigationDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    var webView: WKWebView!
    var url: URL!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Appearance.main500
        
        // Настройка и добавление webView
        webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.backgroundColor = Appearance.main500
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        webView.layer.masksToBounds = true
        
        // Настройка и добавление activityIndicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Appearance.main300
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Загрузка запроса
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Скрытие большого заголовка в navigationBar
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // WKNavigationDelegate методы для управления состоянием activityIndicator
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}

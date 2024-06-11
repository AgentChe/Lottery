//
//  MenuViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Define the menu items
    private let menuItems = ["Games", "State", "Terms of Use", "Privacy Policy", "Support"]
    
    // Create a table view
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Appearance.main500

        setupNavigationBarItems()
        setupTableView()
    }

    // Setup navigation bar items (left: Menu, right: Close button)
    private func setupNavigationBarItems() {
        // Create the Menu label as the left bar button item
        let menuLabel = UILabel()
        menuLabel.text = "MENU"
        menuLabel.textColor = Appearance.mono200
        menuLabel.font = Fonts.Inter.bold(size: 20.scale)
        let menuBarItem = UIBarButtonItem(customView: menuLabel)
        navigationItem.leftBarButtonItem = menuBarItem
        
        // Create the Close button as the right bar button item
        if let closeImage = UIImage(named: "SuggestNewGame.Close") {
            // Create the UIImageView with aspect fit
            let closeImageView = UIImageView(image: closeImage)
            closeImageView.contentMode = .scaleAspectFit
            
            // Set the height of the image view to match the menu label's height
            let menuLabelHeight = menuLabel.intrinsicContentSize.height
            closeImageView.frame = CGRect(x: 0, y: -0.5, width: menuLabelHeight, height: menuLabelHeight)
            closeImageView.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
            
            // Wrap the image view in a UIView to manage its layout
            let closeContainerView = UIView(frame: closeImageView.frame)
            closeContainerView.addSubview(closeImageView)
            
            // Create the UIBarButtonItem with the custom view
            let closeBarItem = UIBarButtonItem(customView: closeContainerView)
            navigationItem.rightBarButtonItem = closeBarItem
            
            // Add tap gesture to the image view for close action
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
            closeContainerView.isUserInteractionEnabled = true
            closeContainerView.addGestureRecognizer(tapGesture)
        }
    }
    
    // Setup the table view
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear // To match the view background
        
        // Set row height to 56
        tableView.rowHeight = 56
        
        // Disable default separator
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        // Set constraints for the table view
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // Handle the menu button tap to close the view controller
    @objc private func closeMenu() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.font = Fonts.Inter.medium(size: 14)
        cell.textLabel?.textColor = Appearance.mono200
        cell.backgroundColor = Appearance.main500
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           // Deselect the cell immediately after selection
           tableView.deselectRow(at: indexPath, animated: true)
           
           // Handle menu item selection with a switch statement
           let selectedItem = menuItems[indexPath.row]
           
           switch selectedItem {
           case "Games":
               print("Selected Games")
               // Add your action here for "Games"
               navigateToGames()
               
           case "State":
               print("Selected State")
               // Add your action here for "State"
               navigateToState()
               
           case "Terms of Use":
               print("Selected Terms of Use")
               // Add your action here for "Terms of Use"
               navigateToWebView(with: GlobalDefinitions.termsOfUseUrl)
               
           case "Privacy Policy":
               print("Selected Privacy Policy")
               // Add your action here for "Privacy Policy"
               navigateToWebView(with: GlobalDefinitions.privacyPolicyUrl)
               
           case "Support":
               print("Selected Support")
               // Add your action here for "Support"
               navigateToWebView(with: GlobalDefinitions.contactUsUrl)
               
           default:
               print("Unknown selection")
           }
       }
    // Navigation methods for each menu item (replace these with actual implementations)
      private func navigateToGames() {
          // Implement navigation to Games screen
          print("Navigating to Games screen...")
      }
      
      private func navigateToState() {
          // Implement navigation to State screen
          print("Navigating to State screen...")
      }
      
      private func navigateToWebView(with url: URL) {
          let settingsWebViewController = SettingsWebViewController()
          settingsWebViewController.url = url
          present(settingsWebViewController, animated: true, completion: nil)
      }
}

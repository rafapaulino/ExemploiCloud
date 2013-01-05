//
//  ViewController.h
//  ExemploiCloud
//
//  Created by Rafael Brigagão Paulino on 18/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tabela;
@property (weak, nonatomic) IBOutlet UITextField *campoDeTexto;

- (IBAction)adicionarAnotacao:(id)sender;
- (IBAction)atualizar:(id)sender;
@end

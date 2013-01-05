//
//  ViewController.m
//  ExemploiCloud
//
//  Created by Rafael Brigagão Paulino on 18/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "ViewController.h"
#import "GerenciadorArquivo.h"

@interface ViewController ()
{
    NSMutableArray *arrayAnotacoes;
    
    GerenciadorArquivo *gerenciador;
    
    //objeto que vai nos auxiliar a fazer uma busca por um documento no icloud
    NSMetadataQuery *busca;
    
    //url da pasta raiz da aplicacao no icloud
    NSURL *ubiq;
    
    //url do arquivo em si
    NSURL *urlArquivo;
}

- (void)buscaPronta:(NSNotification*)notification;

@end

@implementation ViewController
@synthesize tabela;
@synthesize campoDeTexto;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    arrayAnotacoes = [[NSMutableArray alloc] init];
    
    //pegar a url da pasta raiz do app
    //URLForUbiquityContainerIdentifier:nil retorna a pastaraiz do app (se colocar algo no lugar do nil ele pdega outra pasta
    ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq != nil)
    {
        UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"iCloud OK" message:@"iCloud disponivel" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alerta show];
        
        [self atualizar:nil];
    }
    else
    {
        UIAlertView *alerta = [[UIAlertView alloc] initWithTitle:@"Erro no iCloud" message:@"iCloud nao disponivel" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alerta show];
    }
    
    
}

- (void)viewDidUnload
{
    [self setTabela:nil];
    [self setCampoDeTexto:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)adicionarAnotacao:(id)sender
{
    [campoDeTexto resignFirstResponder];
    
    [arrayAnotacoes addObject:campoDeTexto.text];
    
    gerenciador.arrayDeAtualizacao = arrayAnotacoes;
    
    [gerenciador saveToURL:[gerenciador fileURL] forSaveOperation:UIDocumentChangeDone completionHandler:^(BOOL success) {
        //quando acabar de salvar
        
        if (success)
        {
            NSLog(@"Arquivo Salvo");
            
            [tabela reloadData];
        }
        else
        {
            NSLog(@"Erro ao salvar o arquivo");
        }
    }];
    
}

- (IBAction)atualizar:(id)sender
{
   //procurar se ja tem o nosso arquivo la na pasta documents do icloud
    busca = [[NSMetadataQuery alloc] init];
    
    //avisar para a busca que queremos procurar por documentos
    [busca setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    
    //mandar procurar por determinado documento
    //%K = chave de busca
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, @"dadosArquivoOutubro.plist"];
    
    [busca setPredicate:pred];
    
    //vamos nos adicionar no notificationcenter para saber quando essa busca estiver pronta
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buscaPronta) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    
    [busca startQuery];
}


- (void)buscaPronta:(NSNotification*)notification
{
    [busca disableUpdates];
    [busca stopQuery];
    
    //removendo do notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    
    
    //vrerificando se tem algo na busca
    if ([busca resultCount] == 1)
    {
        //captar o item achado no icloud
        NSMetadataItem *item = [busca resultAtIndex:0];
        
        //captar a url do arquivo pesquisado
        urlArquivo = [item valueForAttribute:NSMetadataItemURLKey];
        
        gerenciador = [[GerenciadorArquivo alloc] initWithFileURL:urlArquivo];
        
        //falar para o iCloud baixar o arquivo
        [gerenciador openWithCompletionHandler:^(BOOL success) {
            
            //se tivermos sucesso na busca
            if (success)
            {
                NSLog(@"Arquivo aberto com sucesso!");
                
                arrayAnotacoes = gerenciador.arrayDeAtualizacao;
                
                [tabela reloadData];
            }
            else
            {
                NSLog(@"Erro ao abrir o arquivo!");
            }
        }];
    }
    else
    {
        //caso ele nao tenha encontrado o arquivo, vamos cria-lo
        
        //definir onde salvaremos o arquivo
        //URLByAppendingPathComponent coloca as // no nome do arquivo
        NSURL *percursoParaGravarOArquivo = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"dadosArquivoOutubro.plist"];
        
        gerenciador = [[GerenciadorArquivo alloc] initWithFileURL:percursoParaGravarOArquivo];
        
        gerenciador.arrayDeAtualizacao = arrayAnotacoes;
        
        //bloco de complemento de quando foi concluido o salvamento do arquivo no icloud
        [gerenciador saveToURL:[gerenciador fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            if (success)
            {
                NSLog(@"Documento criado no iCloud");
            }
            else
            {
                NSLog(@"Erro ao criar o documento");
            }
            
        }];
        
    }
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayAnotacoes count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *celula = [tableView dequeueReusableCellWithIdentifier:@"idCell"];
    
    if (!celula)
    {
        celula = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCell"];
    }
    
    celula.textLabel.text = [arrayAnotacoes objectAtIndex:indexPath.row];
    
    return celula;
        
}

@end

//
//  GerenciadorArquivo.m
//  ExemploiCloud
//
//  Created by Rafael Brigagão Paulino on 18/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "GerenciadorArquivo.h"

@implementation GerenciadorArquivo

- (id)initWithFileURL:(NSURL *)url
{
    self = [super initWithFileURL:url];
    
    if (self)
    {
        _arrayDeAtualizacao = [[NSMutableArray alloc] init];
    }
    return self;
}

//para que esta classe possa salvar e ler do iCloud, devemos sobreescrever esses metodos abaixo



//metoso chamado pelo icloud para solicitar os dados de um arquivo que vai ser salvo nele - UPLOAD
- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    //devemos enviar para o iCloud um NSData do conteudo que queremos salvar
    
    //passamos um array e ele e transformado em nsdata
    NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:_arrayDeAtualizacao];
    
    return dataArray;
}


//metodo acionado quando queremos ler um conteudo do icloud
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    //verificar se veio um conteudo
    if ([contents length] > 0)
    {
        //pegar o nsdata e transformar em um array
        _arrayDeAtualizacao = [NSKeyedUnarchiver unarchiveObjectWithData:contents];
        
        return YES;
    }
    
    return NO;
}




@end

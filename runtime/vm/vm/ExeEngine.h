//
//  ExeEngine.h
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//


#ifndef ExeEngine_h
#define ExeEngine_h

class Env;

class ExeEngine {
public:
    virtual bool run(Env *env) = 0;
    virtual ~ExeEngine() {}
};

#endif /* ExeEngine_h */

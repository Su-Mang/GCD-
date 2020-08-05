//
//  ViewController.m
//  GCD 线程安全
//
//  Created by Sumang on 2020/8/3.
//  Copyright © 2020 Sumang. All rights reserved.
//

#import "ViewController.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>
#import <pthread.h>
@interface ViewController ()
@property (assign, nonatomic) int ticketsCount;
@property (assign, nonatomic) int money;
@property (assign, nonatomic) OSSpinLock  spinLock;
@property (assign, nonatomic) os_unfair_lock lock;
@property (assign,nonatomic) pthread_mutex_t * pthread_mutex_tlock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self moneyTest];
    [self ticketTest];
  //  [self otherTest];
}



    


-(void) moneyTest {
    self.money = 100;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++) {
                  [self saveMoney];
              }
    });
    
    dispatch_async(queue, ^{
           for (int i = 0; i < 10; i++) {
                     [self drawMoney];
                 }
       });
       
    
    
}

/**
 存钱
 */
- (void)saveMoney
{
    int oldMoney = self.money;
    sleep(.2);
    oldMoney += 50;
    self.money = oldMoney;
    
    NSLog(@"存50，还剩%d元 - %@", oldMoney, [NSThread currentThread]);
}
/**
取钱
*/
- (void)drawMoney
{
    int oldMoney = self.money;
    sleep(.2);
    oldMoney -= 20;
    self.money = oldMoney;
    
    NSLog(@"取20，还剩%d元 - %@", oldMoney, [NSThread currentThread]);
}
/**
 卖1张票
 */
- (void)saleTicket
{
  //  初始化自旋锁
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//         self.spinLock = OS_SPINLOCK_INIT;
//    });
    
    //初始化 OS_UNFAIR_LOCK
//    static dispatch_once_t onceToken;
//       dispatch_once(&onceToken, ^{
//            self.lock = OS_UNFAIR_LOCK_INIT;
//       });

    
  //初始化锁的属性
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, 0);
  //初始化锁
    
    static dispatch_once_t onceToken;
           dispatch_once(&onceToken, ^{
               pthread_mutex_init(&_pthread_mutex_tlock, &attr);
           });
    
   // OSSpinLockLock(&_spinLock);
   // os_unfair_lock_lock(&_lock);
    pthread_mutex_lock(&_pthread_mutex_tlock);
    int oldTicketsCount = self.ticketsCount;
  
    oldTicketsCount--;
    self.ticketsCount = oldTicketsCount;
    
    NSLog(@"还剩%d张票 - %@", oldTicketsCount, [NSThread currentThread]);
    //OSSpinLockUnlock(&_spinLock);
    //os_unfair_lock_unlock(&_lock);
     pthread_mutex_unlock(&_pthread_mutex_tlock);
}

/**
 卖票演示
 */
- (void)ticketTest
{
    self.ticketsCount = 15;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
             [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
}



@end

//
//  TrailerViewController.m
//  Flix
//
//  Created by Surbhi Jain on 6/25/21.
//

#import "TrailerViewController.h"

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webKitView;
@property (nonatomic, strong) NSURL *trailerUrl;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchTrailer];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapExit:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchTrailer {
    
    NSString *stringMovieID = [self.movie[@"id"] stringValue];
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed", stringMovieID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Trailer"
                 message:@"The Internet connection appears to be offline" preferredStyle:(UIAlertControllerStyleAlert)];

               // create a try again action
               UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * _Nonnull action) {
                   [self fetchTrailer];
                }];
               // add the try again action to the alert controller
               [alert addAction:tryAgain];
               [self presentViewController:alert animated:YES completion:^{

               }];
           }
//        // if JSON is properly returned
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSArray *videos = dataDictionary[@"results"];
               NSDictionary *trailer = videos[0];
               NSString *key = [trailer objectForKey:@"key"];
               
               NSString *trailerStringUrl = [@"https://www.youtube.com/watch?v=" stringByAppendingString:key];
               self.trailerUrl = [NSURL URLWithString:trailerStringUrl];
               
               NSURLRequest *request = [NSURLRequest requestWithURL:self.trailerUrl
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                    timeoutInterval:10.0];
               // Load Request into WebView.
               [self.webKitView loadRequest:request];

               // reload table once data is actually received
               [self.webKitView reload];
           }
       }];
    [task resume];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

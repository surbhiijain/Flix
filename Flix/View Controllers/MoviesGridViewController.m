//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Surbhi Jain on 6/24/21.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDelegate,UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredMovies;



@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
        
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:(UIControlEventValueChanged)];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];

    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 75, 75);
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.color = [UIColor whiteColor];
    self.activityIndicator.backgroundColor = [UIColor lightGrayColor];
    self.activityIndicator.layer.cornerRadius = 10;
    
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    layout.minimumLineSpacing = 5; // vertical spacing
    layout.minimumInteritemSpacing = 5; // horizontal spacing
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    // Do any additional setup after loading the view.
}

- (void)fetchMovies {

    [self.collectionView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.collectionView.alpha = .8;
    // code copied from codepath that sends and processes API get request
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/297762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                 message:@"The Internet connection appears to be offline" preferredStyle:(UIAlertControllerStyleAlert)];
               
               // create a try again action
               UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * _Nonnull action) {
                   [self fetchMovies];
                }];
               // add the try again action to the alert controller
               [alert addAction:tryAgain];
               [self presentViewController:alert animated:YES completion:^{

               }];
           }
        // if JSON is properly returned
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               
               self.movies = dataDictionary[@"results"];
               self.filteredMovies = self.movies;
               
               // reload table once data is actually received
               [self.collectionView reloadData];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

// updating filtered movies whenever text is put into search bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.filteredMovies = self.movies;
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@)", searchText];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
                
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.collectionView reloadData];
 
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
// Function called when moving towards the next screen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.item];
    DetailsViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredMovies[indexPath.item];

    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    [self.activityIndicator stopAnimating];
    self.collectionView.alpha = 1;
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

@end

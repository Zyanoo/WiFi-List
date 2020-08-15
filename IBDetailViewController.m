#import "IBDetailViewController.h"
#import "IBWiFiNetwork.h"
#import "IBDictionaryViewController.h"
#import "IBShareViewController.h"

@interface IBDetailViewController () 
@property (nonatomic, strong) IBWiFiNetwork *network;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation IBDetailViewController

- (id)initWithNetwork:(IBWiFiNetwork *)network; {
    if (self = [super initWithStyle:UITableViewStyleInsetGrouped]) {
        self.network = network;

        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"dd MMM yyyy HH:mm"];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    self.title = self.network.name;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 3;
    }

    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Network Info";
    } else if (section == 1) {
        return @"Dates";
    }

    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"SSID";
            cell.detailTextLabel.text = self.network.name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Password";
            cell.detailTextLabel.text = self.network.password;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Encryption";
            cell.detailTextLabel.text = self.network.encryption == WEP ? @"WEP" : self.network.encryption == WPA ? @"WPA/WPA2" : self.network.encryption == EAP ? @"EAP" : @"None";
        } else {
            cell.textLabel.text = @"Hidden";
            cell.detailTextLabel.text = self.network.isHidden ? @"Yes" : @"No";
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Added";
            cell.detailTextLabel.text = [self.formatter stringFromDate:self.network.added];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Last Manual Join";
            cell.detailTextLabel.text = [self.formatter stringFromDate:self.network.lastManualJoin];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Last Auto Join";
            cell.detailTextLabel.text = [self.formatter stringFromDate:self.network.lastAutoJoin];
        }
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"View Raw Data";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @"Create QR Code";
        cell.textLabel.textColor = [UIColor linkColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        IBDictionaryViewController *viewController = [[IBDictionaryViewController alloc] initWithDictionary:self.network.allRecords];
        [self.navigationController pushViewController:viewController animated:true];
    } else if (indexPath.section == 3 && self.network.encryption == EAP) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Sharing Enterprise networks is not supported" preferredStyle:UIAlertControllerStyleAlert];
	    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
	    [alert addAction:okAction];
	    [self presentViewController:alert animated:YES completion:nil];
    } else if (indexPath.section == 3) {
        IBShareViewController *viewController = [[IBShareViewController alloc] initWithNetwork:self.network];
        [self.navigationController pushViewController:viewController animated:true];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)){
        [[UIPasteboard generalPasteboard] setString:self.network.password];
    }
}

@end
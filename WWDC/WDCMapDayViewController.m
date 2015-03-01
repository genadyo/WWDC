//
//  WDCMapDayViewController.m
//  
//
//  Created by Genady Okrain on 5/18/14.
//
//

#import "WDCMapDayViewController.h"
#import "WDCParty.h"
#import "WDCPartyTableViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import <objc/runtime.h>
#import "WDCParties.h"
@import MapKit;

@interface MKPointAnnotation (WDCPointAnnotation)

@property (strong, nonatomic) WDCParty *party;

@end


static const char kPartyKey;

@implementation MKPointAnnotation (WDCPointAnnotation)

- (WDCParty *)party
{
    return objc_getAssociatedObject(self, &kPartyKey);
}

- (void)setParty:(WDCParty *)party
{
    objc_setAssociatedObject(self, &kPartyKey, party, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@interface WDCMapDayViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation WDCMapDayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Google
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"WDCMapDayViewController"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

    self.title = [((WDCParty *)[self.parties lastObject]) date];

    self.mapView.delegate = self;

    MKCoordinateRegion region;
    region.center.latitude = 37.78417f;
    region.center.longitude = -122.40156f;
    region.span.latitudeDelta = 0.025f;
    region.span.longitudeDelta = 0.025f;
    [self.mapView setRegion:region animated:NO];

    for (WDCParty *party in self.parties) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake([party.latitude floatValue], [party.longitude floatValue]);
        annotation.title = party.title;
        annotation.subtitle = [party hours];
        annotation.party = party;
        [self.mapView addAnnotation:annotation];
    }
}

#pragma - mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    MKPinAnnotationView *v = nil;
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"party"];

        if (!v) {
            v = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"party"];
        }
        if ([[WDCParties sharedInstance].going indexOfObject:((MKPointAnnotation *)annotation).party.objectId] != NSNotFound) {
            v.pinColor = MKPinAnnotationColorGreen;
        } else {
            v.pinColor = MKPinAnnotationColorPurple;
        }
        v.canShowCallout = YES;
        v.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return v;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"party" sender:view.annotation];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"party"]) {
        if ([sender isKindOfClass:[MKPointAnnotation class]]) {
            WDCPartyTableViewController *destController = segue.destinationViewController;
            WDCParty *party = ((MKPointAnnotation *)sender).party;
            destController.party = party;
            [[Mixpanel sharedInstance].people increment:@"WDCMapDayViewController.SegueParty" by:@1];
            [[Mixpanel sharedInstance] track:@"WDCMapDayViewController" properties:@{@"SegueParty": party.title}];
        }
    }
}

@end

//
//  WDCMapDayViewController.m
//  
//
//  Created by Genady Okrain on 5/18/14.
//
//

#import "WDCMapDayViewController.h"
//#import "WDCParty.h"
//#import "WDCPartyTableViewController.h"
//#import "WDCParties.h"
#import <SDCloudUserDefaults/SDCloudUserDefaults.h>
@import MapKit;




@interface WDCMapDayViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation WDCMapDayViewController

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
        v.pinTintColor = [UIColor purpleColor];
        if ([SDCloudUserDefaults objectForKey:@"going"] != nil) {
            if ([[SDCloudUserDefaults objectForKey:@"going"] isKindOfClass:[NSArray class]]) {
                if ([[SDCloudUserDefaults objectForKey:@"going"] indexOfObject:((MKPointAnnotation *)annotation).party.objectId] != NSNotFound) {
                    v.pinTintColor = [UIColor greenColor];
                }
            }
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"party"]) {
//        if ([sender isKindOfClass:[MKPointAnnotation class]]) {
//            WDCPartyTableViewController *destController = segue.destinationViewController;
//            WDCParty *party = ((MKPointAnnotation *)sender).party;
//            destController.party = party;
//        }
//    }
//}

@end

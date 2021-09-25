# sterilize-ng
URL sterilizer - remove tracking information from URLs

## Background

The surveillance capitalist economy is built on the relentless tracking of users. Imagine going about town running errands but everywhere you go, someone is quietly following you. When you pop into the grocery, they examine your receipt. They look into the bags to see what you bought. Then they hop in the car with you and keep careful records of where you go, how fast you drive, whom you talk with on the phone. This is surveillance capitalism - the relentless "digital exhaust" left by our actions online.

The techniques employed by surveillance capitalists are multifold, but one of the easiest to fix is the pollution of URLs with tracking parameters. If you visit a link on Facebook by clicking on it, you are actually giving up a wealth of information about yourself unnecessarily. Here's a typical outgoing link that you would find on Facebook:

<img src="https://github.com/NSBum/sterilize-ng/blob/master/fblink.png" width="50%">

What is all this extra garbage that Facebook attachs to the actual link? Who knows? Somehow Facebook uses this to track your online behaviour. Otherwise, they would just display the actual link, which is quite simply: `https://www.playsmart.ca/social-hub/the-missing-millions/`

## Prerequisites

This was developed on macOS but the much of the code should work as-is on Linux, but I don't have a system to test it on. On macOS, I would suggest installing Homebrew so that you can leverage `proxychains-ng` (installed via Homebrew.) Using proxychains, you can anonymize the expansion of shortened links. If proxychains-ng is not installed, the script will just expand the shortned links without hiding behind proxies.

## Usage

I've made use of `sterilize-ng.sh` by installing in a Keyboard Maesto macro. I right click on a link, copy it to the clipboard, and invoke the KM macro. Then I just paste the sterilized link into a browser. Not as easy as just clicking links; but it's safer and I feel like I'm doing my part to thwart surveillance capitalism.

### Testing

<img src="https://github.com/NSBum/sterilize-ng/blob/master/testing.mov" width="50%">

You can run a test suite of sorts by loading links in the `test_links_sterilize.csv` file. These are just pairs of URLS - original (unsterile) and sterilized links. To use the testing facility, run `test_sterilize_links.sh`.

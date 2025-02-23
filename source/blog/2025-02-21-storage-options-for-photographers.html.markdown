---
title: Storage solutions for photographers
author: Michał Zając
tags: photography
---

This is a first post out of two. I planned to include backup options here as well but realized the topics might sound similar but they really merit their own post.

## Outline
As a photographer you have a plethora of options for *storing* your photos. My main goal is to give you a brief rundown of what options you along with their pros and cons so you can make an educated decision. I will try keeping the technical mumbo-jumbo to a bare minimum so this post does not require a PhD in Computer Science but do not hesitate to let me know if there's something that you do not understand so I can try simplifying it.

As far as I'm aware your *storage* options are the following (sorted by the perceived setup complexity):

1. [External HDD](#external-hdd)
1. [Cloud storage](#cloud-storage)
1. [Prebuilt NAS](#prebuilt-nas)
1. [DIY NAS](#diy-nas)

I'm a **huge fan** of DYI NAS or having a homelab but I do realize not everyone has the energy/time to build one.

## tl;dr

Here's my **very opinionated** flowchart

![Your options](2025-02-21-storage-options-for-photographers/choices.svg)

## <a name="external-hdd"></a>External HDD
I think everyone is familiar with this - you most likely bought something like [this portable HDD](https://www.seagate.com/gb/en/products/external-hard-drives/portable-drive/) or a [bigger, external one](https://www.seagate.com/gb/en/products/external-hard-drives/expansion-desktop-hard-drive/) and you just put all your stuff in there.

### Pros:
* **Simple** - just plug it in and copy the files.

### Cons:
* **Only one device can access the data at a time** - unless you share it over the network.
* **No redundancy** - if the disk stops working for some reason then you have to stop working and look for your backups.
* **Bizarre devices** - I will not claim this is a common scenario but for example, this [WD My Book Duo description](https://www.westerndigital.com/en/products/external-drives/wd-my-book-duo-usb-3-1-hdd?sku=WDBFBE0200JBK-EESN) will say `Archive your collections of photos, videos, music, and vital and historical documents securely in one reliable space.` and the default configuration of this device is RAID 0 which is questionable at best. It's also not a NAS because you cannot connect it to a network directly.

## What is redundancy?
In this context, redundancy basically answers the question of what happens when the storage device stops working. No redundancy means that when the drive stops working for some reason, you cannot continue working on your photos and have to restore them from a backup. You do have a backup, right?

## What is <abbr title="redundant array of independent disks">RAID</abbr>?
Some device descriptions will have things like `optimized performance with RAID 0` or `backups your data with RAID 1`. RAID, in simple terms, is a way of connecting multiple disks so that Windows, or whatever operating system you are using, thinks it's a one big device. This unlocks certain possibilities that are simply undoable with a single drive or multiple drives that are connected independently. This can be *very good thing* or *a very bad thing* if done incorrectly.

RAID has this thing called level which basically tells the computer how to distribute the data across the drives.

The My Book Duo thing I mentioned above uses RAID 0 by default. It has 2 drives. RAID 0 means the data is distributed among all of the hard drives. The upside is that you gain speed that way and the available space is a sum of space of all drives. The downside is that you **lose all data if any single of those drives stops working**. Yes, you read that right - **all data will be lost if one of the drives fails**. *Yikes*.

RAID 1 distributes a copy of the data to **all** drives so you end up with a mirror copy on half of the drives. The upside is that if one of the drives fails then you can continue working because you will be reading the data off the second drive. You can replace the faulty drive immediately or later. The downside is that if you have **two** 10 TB drives the usable space will be only 10 TB.

When I said that `you can continue working`, I meant this quite literally - the drive failure is *totally transparent* to the operating system so you will not even notice it until the technology powering your RAID tells you that one drive has failed.

Be sure to ask me how did I end up not replacing a dead hard drive in my home server for at least two months.

Wikipedia has a great [article on RAID](https://en.wikipedia.org/wiki/RAID) so I recommend skimming it if you are interested in more details.

## RAID 1 is not a backup
There is a another problem with the `backups your data with RAID 1` statement. It is false. RAID 1 is not a backup mechanism. It is a redundancy mechanism only. If you delete a file by accident then RAID 1 will happily propagate the deletion to the other drive and... you're out of luck if you do not have a backup. Your PC is hit by ransomware? RAID 1 will happily encrypt all the files on your other drive.

**RAID is to be used alongside backups, not instead of backups.**

## <a name="cloud-storage"></a>Cloud storage
From Google Photos or Flickr through [IDrive](https://www.idrive.com/) or [Ente](https://ente.io/) (my favourite) all the way down to [Amazon Glacier](https://aws.amazon.com/s3/storage-classes/glacier/) - you basically throw money at the organization of your choice and they give you space and some availability guarantees.

### Pros
* **Infinite scaling** - theoretically the only limit here is the depth of your wallet. Want to store 2 TB of data? Ente will set you back 240 EUR/year. Need 5 TB? IDrive will cost you 100 USD/year. Need 20 TB? AWS Glacier will cost you 486 USD/year with ridiculous data durability guarantees (more if you actually need to access the data).
* **Easy setup** - usually this kind of services have a web interface so if you know how to use one then you are set. There's a probably a mobile application as well or a desktop application for seamless synchronization of files.
* **Available everywhere** - unless you expose your server to the internet then you will not be able to access the files there which might or might not be a problem for you. Exposing your server to the internet is not really a big problem but you need to take certain steps to secure it. With cloud offerings you have nothing to do.
* **High availability** - it is theoretically Google's problem if the service stops working so you do not have to care but if it stops working then there is not much you can do until they fix it.

### Cons
* **Cost** - 20 TB HDD is around 230 USD. It has a 3 year warranty so we're at 6.4 USD per TB per month. Closest you can get is 5 TB from IDrive which is around 8.30 USD per TB per month. My HDD calculation is very pessimisstic because [according to BackBlaze](https://www.backblaze.com/blog/hard-drive-life-expectancy/) nearly 95% of consumer Segate drives survive **at least** five years. This brings the cost to around 3.8 USD per TB per month. Cloud is *really* expensive.
* **Vendor lock-in** - they will make it as hard as possible for you to quit. They can also change the price at will. At first Google told you that you can store as much as you want, then they told you that you can store as much as you want as long as you let them compress your photos. Then they introduced limits and then increased the price. Sure there's Google Takeout but have you ever used it? I did and it is horrible. Not only did I lose a big percentage of metadata but some of the files are unreadable and there is absolutely nothing I can do about it.
* **Privacy concerns** - this is a can of worms. Companies might claim they do not use your data for training AI/profiling/whatever but you have absolutely no guarantees whether or not that is true unless you literally encrypt everything.

## <a name="prebuilt-nas"></a>Prebuilt NAS
Some companies build and sell their own NAS devices like [this](https://www.westerndigital.com/products/cloud-storage/wd-my-cloud-home?sku=WDBVXC0020HWT-NESN) or [this](https://www.qnap.com/en/product/ts-264). They are basically small computers with two (or more) hard drives inside them which are able to connect to your home network via Wi-Fi or cable.

### Pros
* **Simple setup** - you buy one, plug it in, read the manual and it will probably work
* **Looks good** - it's usually a black or white cuboid and has two cables going into it so yeah
* **Possible redundancy** - some NAS devices might have `RAID` anywhere in their description, this means they **can** have some redundancy. It can be configured in a manner that is inappropriate for our needs so be careful.

### Cons
* **Cost** - usually more expensive than sum of their parts.
* **Vendor lock-in** - this kind of device usually has some sort of operating system installed on it and you cannot change it, perhaps it might require some kind of subscription for some functionality. Some devices might not allow you to swap drives or use whatever drive you have at hand. For example [this device](https://www.westerndigital.com/products/cloud-storage/wd-my-cloud-home?sku=WDBVXC0080HWT-NESN) has absolutely no support for swapping disks but [this one](https://www.qnap.com/en/product/ts-264) has a [compatibility list](https://www.qnap.com/en/compatibility/?model=635&category=1&filter[type]=1) so you can check if the drive you have or bought will work. Carefully asses what your options are before buying one.

## <a name="diy-nas"></a>DIY <abbr title="Network Attached Storage">NAS</abbr>
With all of that redudndancy and RAID out of way we can proceed to our next storage method - do-it-yourself NAS. This is basically any kind of PC which shares storage space over the network. You can use a [Raspberry Pi](https://www.raspberrypi.com/) with an external HDD attached. Perhaps you have an old laptop laying around? That works as well. Maybe you can get an old PC for free from Craigslist or whatever your local equivalent is. It doesn't have to (but can) be a powerful machine. Literally anything that has a USB port and a way to connect (perferably cable) to your home network will do.

I, for example, have [this Western Digital hard drive](https://www.westerndigital.com/products/external-drives/wd-elements-desktop-usb-3-0-hdd?sku=WDBWLG0180HBK-NESN) connected to my Raspberry Pi which is set up to share the drive over the network.

![DIY NAS using a Raspberry Pi with an external hard drive](2025-02-21-storage-options-for-photographers/diy-nas-pi.jpg)

Doesn't look nice but gets the job done. Don't ask me about the ketchup though.

### Pros
* **Cheap** - most likely you already have an old PC/laptop or can easily get one
* **Flexible** - you can use whatever PC/laptop and whatever drive is handy and swap them at will
* **Avoid vendor-lock in** - prebuilt NAS servers usually have some software running on it which might require subscription for some of it's features or perhaps are no longer supported so you will be stuck with whatever your vendor gives you
* **Possible redundancy** - if you have enough drives then you can set it up.

### Cons
* **Requires tinkering** - there are multiple tutorials on how to do it and I might write one at some point for completeness. If you do not have a few hours to spare then it's perhaps not a solution for you. It's not rocket science but it's not a three step process as well.
* **Looks bad** - this is subjective and you can get around it if you want to but it's probably not going to be as sleek-looking as a prebuilt NAS is.
* **Requires maintenance** - this is debatable, I have not touched my Raspberry Pi setup for over 4 years because I was lazy and I had absolutely 0 problems but some people might tell you it will break and you will have to spend hours on debugging issues.

## Summary

We have somehow managed to briefly cover possible storage options available to you as a photographer. The next post will be about backup solutions for your photos. Some of things you see here - most likely cloud-based solutions will reappear.

If you found any big errors here then please let me know. I usually hang out around the [Discord server](https://discord.gg/tbng4W9w3r) for The Focal Point community. Alternatively find me on Twitter (or whatever it name is at the moment).


![](https://cdn-images-1.medium.com/max/2000/1*2IUCSZbJPtf8jK0XMLS9SQ.jpeg)

# How I downloaded Big Bang Theory Season 9 in my unstable network.

I take serious measures to get things right when it comes to downloading TV series. But today, I have been proven wrong. My day goes like this.

I planned to download Big Bang Theory Season 9 after another exhausting FRIENDS marathon AGAIN. I followed the routine.
>  Put the torrent magnet on direct-torrents and wait for it to be seeded.

I even clicked the → button and believed it would actually fasten it. But It almost took three hours to be seeded and the file to be available.

I have a **512kbps** extremely unstable internet connection. It would take a day to download **3GB.** I hate downloading files via Chrome because you can never resume a download there. So I use **wget **and there comes my 2nd problem. The files were served via *SSL *and so **wget** kept throwing me *403:FORBIDDEN*. I tried the download on Chrome and it was working fine. So I made my **wget **fake the connection that the request was actually from the browser by changing the User-Agent. With a simple **wget -U “Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36” **the download starts working.
> ETA 22 hours.

As I expected, It was going to take a whole day to complete the download. It was midnight and I had to find something to keep me occupied for *one whole day which doesn't involve my laptop*. Right then, I got a text message.
> "Buy 2 Get 3 free".

Problem Solved. But the bus trip was gonna be boring. So I thought maybe I can download a movie which I could watch on the trip. I deleted Big Bang Theory from the queue in a way that doesn’t affect my download and added FINDING DORY ❤ to the queue. Since the torrent had a high number of seeders, It was instantly available.
> ETA 10 hours.

I had to leave the by 6am. So I stopped Big Bang Theory download. But direct-torrents doesn't have a **user cache**. So I had to seed Big Bang Theory all over again because I deleted it from the queue. I added it to the queue and the movie was downloading without any trouble. Time for a pleasant sleep.
> ETA 4 hours. The next day.

I woke up and found FINDING DORY downloaded and Big Bang Theory was ready to be downloaded again. But I had already downloaded some part of that zip file. Thanks to **wget -c, **it was back on track resuming from the part where I stopped the download. I was going to leave my laptop unattended for a whole day and so I prepared it for the worst. I gave it the lowest display power and lock screen on 5 seconds of inactivity. I could have just closed the lid and went with no suspend but somehow it interfered with my Wi-Fi connection. My laptop can run for 3 hours without power in this setting and that's better than most.

![No Interruptions _/\_](https://cdn-images-1.medium.com/max/4480/1*SJMEvY9zd_feOEIanxY4nQ.jpeg)
> ETA 18 hours.

I returned home by midnight. I get into my room to check the download. It was at 98% but has become static. This means direct-torrents removed the file as I couldn’t complete the download in a day. So I add the file again and waited for another 3 hours.
> ETA 20 minutes.

It was wget time. The download ran for some time and again stopped because of network reset. I use **wget -c **to get it back and I know the file is still available because if not I would have got a **404**. The terminal said.

    The file is already fully retrieved; nothing to do.  

But I'm aware the download stopped at 99%. This means I have a broken zip which I am unable to resume.
> ETA 10 minutes.

So I thought maybe I could extract the zip file and just download the files that are damaged. Extraction succeeded. Yay!!

![WTF](https://cdn-images-1.medium.com/max/2000/1*jymvBMivUcOZwmFmgblANg.png)

The folder contained 48 SRT files alone.

![](https://cdn-images-1.medium.com/max/2244/1*eIj1p3rl9izgBl39uMl9Mg.png)

The zip file was clearly **3.6GB** but the extraction only had 44 SRT files which were merely **1.5MB**. Back to square 1.
> ETA -_- I still didn’t lose hope.

I opened the file in Bless and checked for .mp4 hex. Results found : 72.

![](https://cdn-images-1.medium.com/max/2000/1*eE19PS41VY_T6FQDA7lkdw.png)

So Yes, All the episodes were in there but I couldn't extract them.

I tried to fix the zip file with **zip -FF** but it just returned me an empty zip file.

![Trying to fix it.](https://cdn-images-1.medium.com/max/2244/1*PsUK7GB2wmYtvqUI3qWqjg.png)

![](https://cdn-images-1.medium.com/max/2244/1*xgJlLARsyuAN3SUQxnUQBw.png)

The file wasn't broken but something has gone wrong. I go back to the torrent site to check the file structure. The zip file consisted of all episodes in mp4 and a compressed file of all subtitles.

![](https://cdn-images-1.medium.com/max/2824/1*3NCfSAWoi-sbUiR2d7bHqg.png)

Out of options, I tried unzipping the file from the command line with **unzip**.

![](https://cdn-images-1.medium.com/max/2244/1*HhyXwpRM_PmiRYcdi8hWKQ.png)

It threw an error "*End-of-central-directory signature not found*".

The problem was clear now. The file download wasn't completed. When the network reset occurred, the compressed file with subtitles was downloaded. When I tried to resume to download there was an EOF mismatch with both compressed files which made wget think it had fully retrieved the file.That is why on extraction in GUI, I got the 48 srt files and the **zip -FF **couldn’t fix the zip**.**

![AAH! Finally an Explanation.](https://cdn-images-1.medium.com/max/2000/1*AfTpuv_-Eiueco0nexzz6Q.jpeg)
> ETA 0 minutes.

Time to Google. I checked for file extractors which doesn't check for EOF. After an extensive search and skimming through stack-overflow, I found that jar files were actually inner zip files but don’t have a *End-of-central-directory signature*.

I took a leap of faith and tried to extract zip files as how we would extract a jar file using **jar -xvf**.

![](https://cdn-images-1.medium.com/max/2244/1*O_cMzK0UqdcHxmESJ6JQnQ.png)

The mp4 files were extracted one by one and the corrupted file was just the sample mp4. At 4am, I finally downloaded Big Bang Theory season 9 completely.

![](https://cdn-images-1.medium.com/max/2000/1*IoyFqCeals3msgo9OPdRgA.jpeg)

To be honest, the season sucked BIG TIME.

![Just WHY](https://cdn-images-1.medium.com/max/2000/1*qxSPFXFYgmi3As8w7Gir2A.jpeg)

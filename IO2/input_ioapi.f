c**********************************************************************
      subroutine input1(istday2,ut,iperiod2,ix,iy,iz,t,sg1,sl1,sp1,
     &    tlon,tlat,h,deltah,hdz,dx,dy,dz,
     &    dht,sigmaz,baseh,dt2,iunit,iout)
c****************************************************************************
c---+----1----+----2----+----3----+----4----+----5----+----6----+----7-----
      include 'PARMS3.EXT'      ! i/o API
      include 'FDESC3.EXT'      ! i/o API
      include 'IODECL3.EXT'     ! i/o API      

      parameter (mxspg=250)
      include 'aqindx.cmm'
      include 'aqcon1.cmm'
      include 'aqsymb.cmm'
      include 'aqcont.cmm'
cc
      dimension sg1(ix,iy,iz,1),sl1(ix,iy,iz,1),sp1(ix,iy,iz,1)
      dimension work(ix,iy,iz,mxspg)
      dimension tlon(ix,iy),tlat(ix,iy),h(ix,iy),t(ix,iy,iz)
      dimension hdz(ix,iy,1),dz(ix,iy,1),sigmaz(1),istday(3)
      real deltah(ix,iy)
      dimension istday2(3)
      dimension iunit(25),iout(25),idum1(3),dx(1),dy(1)
      logical nflag     
cc
      namelist /aqtime/istday,isthr,iperiod,iprnt,dt
c------------------------------------------------------------------------
c     read namelist input file
      open(11,file='aqms.mif',status='old')
      read(11,aqtime)
      dt2=dt
      iperiod2=iperiod
      do i=1,3
       istday2(i)=istday(i)
      enddo
      close(11)
      ut=isthr
c     call datec
c     call headline
c-------------------------------------------------------------------------
c     open all the data file
      call aq_open(numl,istday(1),istday(2),istday(3),isthr,
     1              sigmaz,dht,iz)
c-------------------------------------------------------------------------      
c        read geological data: longitude, latitude, terrain base ht

      if(.not.open3('HEIGHT3D',FSREAD3,'aq_open')) then  ! for MM5 output
        print*, 'failed to open HEIGHT3D in input1'
        stop
      endif
      call READ_IOAPI('HEIGHT3D','AGL',1000, 1, 1, 0, hdz,iflag)
      if(iflag.ne.0) then
       print*,'failed to get height information from HEIGHT3D'
       stop
      endif
      nflag=close3('HEIGHT3D')

      call READ_IOAPI('DOMAIN','LON',1000, 1, 1, 0, tlon,iflag)
      call READ_IOAPI('DOMAIN','LAT',1000, 1, 1, 0, tlat,iflag)
      call READ_IOAPI('DOMAIN','TOPO',1000, 1, 1, 0, h,iflag)

            
      if(iz.gt.2) then
         do 10 i=1,ix
          do 10 j=1,iy
           do k=1,iz
            hdz(i,j,k)=hdz(i,j,k)+h(i,j)   ! altitude above sea level
           enddo
          do 10 k=2,iz
           dz(i,j,k-1)=hdz(i,j,k)-hdz(i,j,k-1)
10       continue
      endif
            
c-------------------------------------------------------------------------
c                                 initial condition
c     call aq_readhd(iunit(3),1)
c     call aq_read_conc(iunit(3),ix*iy*iz,numl(1,3),numl(1,3),
c    1                 sname(1,1),sg1,
c    2 '** error in reading gas initial concentrations **')      

      
      call INTERP_IOAPI('METEO3D','T',                      ! K
     1  istday(1),istday(2),istday(3),isthr,t(1,1,1),ix*iy*iz,idum)
cc
      call INTERP_IOAPI('METEO3D','P',istday(1),             ! Pa
     1 istday(2),istday(3),isthr,sg1(1,1,1,iair),ix*iy*iz,iflag)
c      print*,sg1(10,10,1,iair),sg1(50,50,1,iair)
      print*,' READ initial condition file in input1'

      !**************************************************************
      ! 	Changed from numl(1,3) to numl(1,2)
      !                     Chai, Tianfeng 3/17/2005
      !**************************************************************
      do l=1,numl(1,2) 
       write(6,*), l, sname(l,1)
       if(sname(L,1).eq.'H2SO4') then
        call READ_IOAPI('INITF','H2SO4',
     1  istday(1),istday(2),istday(3),isthr,sg1(1,1,1,L),iflag)

        call READ_IOAPI('INITF','SO41',
     1  istday(1),istday(2),istday(3),isthr,work,iflag)
        sg1(1:ix,1:iy,1:iz,L)=sg1(1:ix,1:iy,1:iz,L)+work(1:ix,1:iy,1:iz)

        call READ_IOAPI('INITF','SO42',
     1  istday(1),istday(2),istday(3),isthr,work,iflag)
        sg1(1:ix,1:iy,1:iz,L)=sg1(1:ix,1:iy,1:iz,L)+work(1:ix,1:iy,1:iz)

        call READ_IOAPI('INITF','SO43',
     1  istday(1),istday(2),istday(3),isthr,work,iflag)
        sg1(1:ix,1:iy,1:iz,L)=sg1(1:ix,1:iy,1:iz,L)+work(1:ix,1:iy,1:iz)

       else if(sname(L,1).eq.'BC') then 
       call READ_IOAPI('INITF','BC1',
     1  istday(1),istday(2),istday(3),isthr,sg1(1,1,1,L),iflag)

        call READ_IOAPI('INITF','BC2',
     1  istday(1),istday(2),istday(3),isthr,work,iflag)
        sg1(1:ix,1:iy,1:iz,L)=sg1(1:ix,1:iy,1:iz,L)+work(1:ix,1:iy,1:iz)

       else if(sname(L,1).eq.'OC') then

        call READ_IOAPI('INITF','OC1',
     1  istday(1),istday(2),istday(3),isthr,sg1(1,1,1,L),iflag)

        call READ_IOAPI('INITF','OC2',
     1  istday(1),istday(2),istday(3),isthr,work,iflag)
        sg1(1:ix,1:iy,1:iz,L)=sg1(1:ix,1:iy,1:iz,L)+work(1:ix,1:iy,1:iz)

       else if(sname(L,1).eq.'SSF') then

        call READ_IOAPI('INITF','SS1',
     1  istday(1),istday(2),istday(3),isthr,sg1(1,1,1,L),iflag)

        call READ_IOAPI('INITF','SS2',
     1  istday(1),istday(2),istday(3),isthr,work,iflag)
        sg1(1:ix,1:iy,1:iz,L)=sg1(1:ix,1:iy,1:iz,L)+work(1:ix,1:iy,1:iz)

       else if(sname(L,1).eq.'SSC') then

        call READ_IOAPI('INITF','SS3',
     1  istday(1),istday(2),istday(3),isthr,sg1(1,1,1,L),iflag)

        call READ_IOAPI('INITF','SS4',
     1  istday(1),istday(2),istday(3),isthr,work,iflag)
        sg1(1:ix,1:iy,1:iz,L)=sg1(1:ix,1:iy,1:iz,L)+work(1:ix,1:iy,1:iz)

      else    ! other than these three species
      write(*,*) istday(1),istday(2),istday(3),isthr,sname(l,1)
      call READ_IOAPI("INITF",sname(l,1),
     1  istday(1),istday(2),istday(3),isthr,sg1(1,1,1,l),iflag)
      endif
 
       if(iflag.eq.1) then
        write(6,*) '** can not find**', sname(l,1) 
       else             !  convert ppbv to molecular/cm3
        do i=1,ix
	 do j=1,iy
	  do k=1,iz
c           sg1(i,j,k,l)=sg1(i,j,k,l)*2.687e+19*
c     &                  sg1(i,j,k,iair)/101300.*273/t(i,j,k)  ! Take out 1e9 because IC in mole fraction, short runs
           sg1(i,j,k,l)=sg1(i,j,k,l)*2.687e+19/1.e9*    
     &                  sg1(i,j,k,iair)/101300.*273/t(i,j,k)  ! Leave in 1e9 because IC in ppb, long runs
          enddo
	 enddo
	enddo  
       endif
      enddo
      
c---------------------------------------------------------------------
      if(ih2o.le.0) then
	 write(6,*) '** critical error: no water species**'
	 stop
      endif
      return
      end   
      
      
c**********************************************************************
      subroutine input2(ix,iy,iz,numsp,it,idate,sg1,u,v,w,kh,kv,t,
     1  wc,wr,rvel,q,em,vg,fz,sprc,sx,sy,sz,dx,dy,hdz,h,cldod,ccover,
     2  kctop,dobson,iunit)
c**********************************************************************
      include 'aqmax.param'
      include 'aqindx.cmm'
      include 'aqspec.cmm'
      include 'aqsymb.cmm'
      parameter (n_var3=11,nelev=12)  ! biomass and dust elevation levels
      parameter (pvo3=33.0)           ! convert factor of PV to ozone
      
      dimension u(ix,iy,1),v(ix,iy,1),w(ix,iy,1),kh(ix,iy,1)
      dimension kv(ix,iy,1),t(ix,iy,1),wc(ix,iy,1),wr(ix,iy,1) ! cloud and rain water
      dimension sg1(ix,iy,iz,1),q(ix,iy,1),em(ix,iy,iz,1)
      dimension rvel(ix,iy,1),idate(3),hdz(ix,iy,1),land(ix,iy)
              ! rvel is rain fall down speed
      dimension vg(ix,iy,1),fz(ix,iy,1),sprc(ix,iy),dx(1),dy(1),
     1  PBL(ix,iy),pv(ix,iy,iz)                  
      dimension sx(iy,iz,2,1),sy(ix,iz,2,1),sz(ix,iy,1)
      dimension iunit(25),scrat(mxgr*4*30)
      real   dobson(ix,iy),h(ix,iy),cldod(ix,iy,iz),ccover(ix,iy,iz) ! cloud coverage
      integer  ikctop(ix,iy)                 ! Cloud top K index
      real     kctop(ix,iy)
      real hdzzz(iz),jz(iz),pz(iz),tz(iz),vapor(iz),cwater(iz),
     1 rwater(iz),wetk(iz,4),biomelev(nelev),dustelev(nelev),cld1d(iz),
     2 cc1d(iz),fixemfac
     
      data biomelev/0.12,0.12,0.11,0.101,0.101,0.096,0.083,0.082,
     1 0.082,0.074,0.018,0.013/
      data dustelev/0.2,0.2,0.2,0.2,0.13,0.01,0.01,0.01,
     1 0.1,0.1,0.01,0.01/

      real kh,kv, concdummy, vcosco2(ix,iy)
      integer weekday, wkday, iv, ij,e1
cc
      ihr=mod(it,24)
c-------------------------------------------------------------------------
c
      jday=julian(idate(1),idate(2),idate(3))+idate(1)*1000

      iweekday=wkday(jday)
      if(iweekday.ge.1.and.iweekday.le.5) then
       weekday=1
      else if(iweekday.eq.6) then        ! Saturday
       weekday=2
      else if(iweekday.eq.7) then        ! Sunday
       weekday=3
      else
       print*,'Error in iweekday ',iweekday,jday,idate(1),idate(2),
     1  idate(3)
       stop
      endif
      !read emissions
      print *, idate(1),idate(2),idate(3),ihr

      call aq_zero_r4(ix*iy*iz*numsp,em)
      call aq_zero_r4(ix*iy*numsp,q)


      do L=1,emnum
       if(emname(L).eq.'DUST'.or.emname(L).eq.'SSF'.or.
     1  emname(L).eq.'SSC') then
         call INTERP_IOAPI('METEO2D',emname(L),                  ! Load dust and sea salt emissions
     1    idate(1),idate(2),idate(3),ihr,q(1,1,L) ,ix*iy,iflag)  !from METEO2D          

       else if(index(emname(L),'BIOG').gt.0) then
       
         call INTERP_IOAPI('BIOGENIC',emname(L),                  ! Load biogenic isoprene and monoterpene
     1    idate(1),idate(2),idate(3),ihr,q(1,1,L),ix*iy,iflag) 
         if(iflag.ne.0) print*,'failed to read ',emname(L),' at ',
     1	  ihr,idate

       else if(emname(L).eq.'LNOX') then
          call INTERP_IOAPI('LIGHTNING',emname(L),                 ! Load lightning emissions from METEO3D
     1    idate(1),idate(2),idate(3),ihr,em(1,1,1,L) ,ix*iy*iz,iflag)          
        do i=1,ix
	 do j=1,iy	 
	  em(i,j,1,L)=em(i,j,1,L)*(hdz(i,j,1)-h(i,j))*2    ! multiplying with the thickness           
          do k=2,iz
            em(i,j,k,L)=em(i,j,k,L)*(hdz(i,j,k)-hdz(i,j,k-1))   
	   enddo
 	  enddo
         enddo
     
       else    
        call READ_IOAPI('EMDAILY',emname(L),       ! read in diurnal-cycle emission
     1    idate(1),idate(2),idate(3), 0, q(1,1,L),iflag)   ! our emission already in molecular/cm2

c        call READ_IOAPI('EMISSION',emname(L),       ! read in diurnal-cycle emission
c     1     2001,1,weekday,ihr, em(1,1,1,L),iflag2)   ! our emission already in molecular/cm2     
        if(iflag.eq.1) then
	call aq_zero_r4(ix*iy*iz,em(1,1,1,L))
	
        call READ_IOAPI('EMHOURLY',emname(L),        ! read in diurnal-cycle emission
     1    idate(1),idate(2),idate(3),ihr, q(1,1,L),iflag2)   ! our emission already in molecular/cm2
        if(iflag2.eq.1) call aq_zero_r4(ix*iy*iz,q(1,1,L))
	endif

	iflag=iflag*iflag2
       endif	


	if (emname(L).eq.'gpp') then

        open(27, file='fixedfac.dat',status='old',IOSTAT = e1)
        do iv = 1, ix
          do jv = 1,iy
               read(27,*) vcosco2(iv,jv)
         enddo
        enddo
        close(27)
	print*, 'DEBUG vcosco2',maxval(vcosco2),minval(q(:,:,L))
	q(:,:,L) = vcosco2 * q(:,:,L)
        print*, 'DEBUG vcosco2',maxval(vcosco2),minval(q(:,:,L))

	endif

c       if(iflag.eq.0) then
c        do i=1,ix                          ! transfer the emission at lowest layer to q
c	 do j=1,iy
c	  do k=1,nelev
c	   if(emname(L).eq.'DUST') then
c	    em(i,j,k,L)=em(i,j,k,L)+q(i,j,L)*dustelev(K)
c	   else if(emname(L).ne.'SSF'.and.emname(L).ne.'SSC') then
c	    em(i,j,k,L)=em(i,j,k,L)+q(i,j,L)*biomelev(K)
c	   endif 	   
c	  enddo 
c	  if(emname(L).eq.'SSF'.or.emname(L).eq.'SSC') 
c     1	   em(i,j,1,L)=em(i,j,1,L)+q(i,j,L)      ! sea salt only in lowest layer
c	  
c          q(i,j,L)=em(i,j,1,L)!/100.
c 	  em(i,j,1,L)=0.
c         enddo
c	enddo
c        do k=2,iz
c         do i=1,ix
c	  do j=1,iy
c           em(i,j,k,L)=em(i,j,k,L)/(hdz(i,j,k)-hdz(i,j,k-1))/100.   ! unit molecues/cm3
c	  enddo
c 	 enddo
c        enddo
c       endif	  
      enddo ! end emission loop

! after whole emissions done, mappping  them to transport species sequence 
	print*,'DEBUG',minval(q(:,:,1)),minval(em(:,:,:,1)) 
      call aq_speci(ix*iy,numsp,emnum,emal,q)          ! area emissions
      call aq_speci(ix*iy*iz,numsp,emnum,emal,em)      ! elevated emissions
      
c-------------------------------------------------------------------
      do l=1,vgnum
      call INTERP_IOAPI('DEPVEL',vgname(l),
     1        idate(1),idate(2),idate(3),ihr,vg(1,1,l),ix*iy,iflag)
      enddo
      
c      call READ_IOAPI('DOMAIN','LANDUSE',1000, 1, 1, 0, land,iflag)
       
c      print *, vgnum 
       
c       do 29 i=1,ix
c       do 29 j=1,iy
c       do 29 k=1,vgnum
c	   if (land(i,j).eq.16) vg(i,j,2) = 0.0       ! case water body
c           if (land(i,j).eq.16) vg(i,j,14) = 0.0
c29     continue
      
      
      if(iflag.eq.0) then
         call aq_speci(ix*iy,numsp,vgnum,vgal,vg)
      endif

      call INTERP_IOAPI('DOBSON','O3-dobson',               
     1     idate(1),idate(2),idate(3),ihr,dobson,ix*iy,idum)
           
      print*,' Read 2D meteorological data in input2 for date',idate(1),
     1 idate(2),idate(3), ihr
      call INTERP_IOAPI('METEO2D','PBLHT',        ! PBL Height in meter above surface
     1     idate(1),idate(2),idate(3),ihr,pbl,ix*iy,idum)
      call INTERP_IOAPI('METEO2D','PRATE',        ! Precipitation rate in mm/hr
     1     idate(1),idate(2),idate(3),ihr,sprc,ix*iy,idum)
c-------------------------------------------------------------------
cc                                        ! read 3D meteorological fields
      print*, 'Read meteorological data in input2 for date',idate(1),
     1 idate(2),idate(3), ihr
      print*,'ix, iy, iz=',ix,iy,iz 
      call INTERP_IOAPI('METEO3D','U',
     1     idate(1),idate(2),idate(3),ihr,u,ix*iy*iz,idum)
cc
      call INTERP_IOAPI('METEO3D','V',
     1     idate(1),idate(2),idate(3),ihr,v,ix*iy*iz,idum)
cc
      call INTERP_IOAPI('METEO3D','W',
     1     idate(1),idate(2),idate(3),ihr,w,ix*iy*iz,idum)
cc
      call INTERP_IOAPI('METEO3D','KV',                     ! m/s2
     1     idate(1),idate(2),idate(3),ihr,kv,ix*iy*iz,idum)
cc
      call INTERP_IOAPI('METEO3D','KH',                     ! m/s2
     1     idate(1),idate(2),idate(3),ihr,kh,ix*iy*iz,idum)
cc
      call INTERP_IOAPI('METEO3D','T',                      ! K
     1    idate(1),idate(2),idate(3),ihr,t,ix*iy*iz,idum)
cc
      call INTERP_IOAPI('METEO3D','P',                       ! Pa
     1  idate(1),idate(2),idate(3),ihr,sg1(1,1,1,iair),ix*iy*iz,iflag)
cc
      call INTERP_IOAPI('METEO3D','VAPOR',           ! water vapor mixing ratio kg/kg
     1  idate(1),idate(2),idate(3),ihr,sg1(1,1,1,ih2o),ix*iy*iz,iflag)
  
      call INTERP_IOAPI('METEO3D','CWATER',    ! Cloud water Content kg/kg
     1  idate(1),idate(2),idate(3),ihr,wc,ix*iy*iz,iflag)

      call INTERP_IOAPI('METEO3D','RWATER',    ! Rain water Content kg/kg
     1  idate(1),idate(2),idate(3),ihr,wr,ix*iy*iz,iflag)

      call INTERP_IOAPI('METEO3D','PV',    ! Potential Vortex
     1  idate(1),idate(2),idate(3),ihr,pv,ix*iy*iz,iflag)
      
c----------------------------------------------------------------------
cc                               !  convert pressure to molecules/cme
      print *,'io3, ico, ich4, ih2, iair, io2, ih2o, ico2, itrace =',
     1  io3, ico, ich4, ih2, iair, io2, ih2o, ico2, itrace
      if(iflag.eq.0) then  ! unit tests  
      do 10 i=1,ix
      do 10 j=1,iy
        hdzzz(1:iz)=hdz(i,j,1:iz)
	pz(1:iz)=sg1(i,j,1:iz,iair)
	tz(1:iz)=t(i,j,1:iz)
	vapor(1:iz)=sg1(i,j,1:iz,ih2o)
        cwater(1:iz)=wc(i,j,1:iz)
        rwater(1:iz)=wr(i,j,1:iz)
       call tuvclouds(iz,hdzzz,h(i,j)+pbl(i,j),pz,  
     1  sprc(i,j),tz,vapor,cwater,rwater,cld1d,cc1d,ikctop(i,j),wetk)   ! computing Cloud optical depth et al
     
       cldod(i,j,1:iz)=cld1d(1:iz)
       ccover(i,j,1:iz)=cc1d(1:iz)
       sg1(i,j,1:iz,nwetso2)=wetk(1:iz,1)
       sg1(i,j,1:iz,nwetso4)=wetk(1:iz,2)
       sg1(i,j,1:iz,nweth2o2)=wetk(1:iz,3)
       sg1(i,j,1:iz,nwethno3)=wetk(1:iz,4)
       kctop(1:ix,1:iy) = ikctop(1:ix,1:iy)
        
       do k=1,iz
       if(cldod(i,j,k).lt.0.or.ccover(i,j,k).lt.0) then
        print*,'CLDOD or CCOVER is negative, stop!',i,j,k,iz,
     1   sprc(i,j),kctop(i,j),wc(i,j,1:iz),cldod(i,j,k),ccover(i,j,k)
        stop
       endif
      enddo 	

      do 10 k=1,iz
      sg1(i,j,k,iair)=2.687e+19*sg1(i,j,k,iair)/101300.*273/t(i,j,k)
		 ! 2.687e+19=avo/22400=6.02e+23/22400 molecules/cm3
      sg1(i,j,k,ih2o)=sg1(i,j,k,ih2o)*28.9/18.0*sg1(i,j,k,iair)
c      sg1(i,j,k,ich4)=1740.*sg1(i,j,k,iair)/1.e9   ! ch4
c     sg1(i,j,k,ico2)=0.00032*sg1(i,j,k,iair)
c      sg1(i,j,k,ih2)=540.*sg1(i,j,k,iair)/1.e9
c      sg1(i,j,k,io2)=0.21*sg1(i,j,k,iair)
c      sg1(i,j,k,in2)=0.78*sg1(i,j,k,iair)
c      sg1(i,j,k,itrace)=1e-6                   ! trace
10    continue

c-------------------------------------------------------
C---- READ Boundary Condition in PPb and convert it molecular/cm3
       print*, 'Read boundary condition in input2 for date',idate(1),
     1 idate(2),idate(3), ihr

      do L=1,numsp
      call READ_IOAPI_BND(sname(l,1),idate(1),idate(2),idate(3),
     1     ihr,ix,iy,iz,sy(1,1,1,l),sx(1,1,2,l),sy(1,1,2,l),
     2     sx(1,1,1,l),scrat)
      do k=1,iz
       do i=1,ix

       sy(i,k,1,L) = 0.467 -  
     c     0.0009*(julian(idate(1),idate(2),idate(3)) - 187) ! 

        sy(i,k,1,L)=sy(i,k,1,L)*sg1(i,1,k,iair)/1e9   ! South boundary

       sy(i,k,2,L) = 0.467 -
     c     0.0009*(julian(idate(1),idate(2),idate(3)) - 187) ! 

c	if (k.lt.11) then
c		sy(i,k,2,L)=sy(i,k,2,L)*0.884 ! add drawdown to north boundary PBL to 398 ppt
c	endif
      if (k.lt.11 .and. i.gt.20) then
               sy(i,k,2,L)=sy(i,k,2,L) - 0.053 ! add drawdown to north boundary PBL to 398 ppt
       endif

	sy(i,k,2,L)=sy(i,k,2,L)*sg1(i,iy,k,iair)/1e9  ! north
       enddo
       do j=1,iy
c	sx(j,k,1,L)=sx(j,k,1,L) - 0.0107 ! decrease west boundary by one stdev of pacific flight observation
c       sx(j,k,1,L)=sx(j,k,1,L) - 
c     c     0.0007*(julian(idate(1),idate(2),idate(3)) - 187) ! decrease west boundary by 0.7 ppt every day following temporal trend in INTEX-NA and NOAA/ESRL data, where 187 is the first day of observations where we set the 480 ppt boundary condition from 

       sx(j,k,1,5) = 0.467 -
     c     0.0009*(julian(idate(1),idate(2),idate(3)) - 187) ! 
       sx(j,k,2,L) = 0.467 -
     c     0.0009*(julian(idate(1),idate(2),idate(3)) - 187) ! 
        sx(j,k,1,L)=sx(j,k,1,L)*sg1(1,j,k,iair)/1e9   !west
	sx(j,k,2,L)=sx(j,k,2,L)*sg1(ix,j,k,iair)/1e9  !east
	enddo
       enddo	
      enddo
c        print*,'DEBUG bc',jday,
c     c     0.007*(julian(idate(1),idate(2),idate(3)) - 187), sx(j,k,1,L)
      
      do K=1,iz              ! trace boundary concentration , 1ppm
        do i=1,ix
	 sy(i,k,1,itrace)=1000*sg1(i,1,k,iair)/1e9
	 sy(i,k,2,itrace)=1000*sg1(i,iy,k,iair)/1e9
	enddo
	do j=1,iy
	 sx(j,k,1,itrace)=1000*sg1(1,j,k,iair)/1e9
	 sx(j,k,2,itrace)=1000*sg1(ix,j,k,iair)/1e9
	enddo 
      enddo

c      do i=1,ix           
c       do j=1,iy                  
c         sz(i,j,io3)=amax1(30.,pv(i,j,iz)*1e6*pvo3)*sg1(i,j,iz,iair)/1e9      ! set pv ozone boundary condition
c	 sz(i,j,io3+numsp)=amax1(30.,pv(i,j,iz-1)*1e6*pvo3)*
c     1	   sg1(i,j,iz-1,iair)/1e9                            !second top boundary
c        enddo
c      enddo
     
c      do j=1,iy                        ! adjust west, east, south and north boundary
c       sx(j,iz,1,io3)=sz(1,j,io3)                        !west
c       sx(j,iz-1,1,io3)=sz(1,j,io3+numsp)
c       
c       sx(j,iz,2,io3)=sz(ix,j,io3)                       !east
c       sx(j,iz-1,2,io3)=sz(ix,j,io3+numsp)                 
c      enddo
      
c      do i=1,ix 
c       sy(i,iz,1,io3)=sz(i,1,io3)                        !south
c       sy(i,iz-1,1,io3)=sz(i,1,io3+numsp)
c       
c       sy(i,iz,2,io3)=sz(i,iy,io3)                       !north
c       sy(i,iz-1,2,io3)=sz(i,iy,io3+numsp)                 
c      enddo
      
             
      do i=1,ix
       do j=1,iy
        sz(i,j,itrace)=1000*sg1(i,j,iz,iair)/1e9
       enddo
      enddo 	

      do L=1,numsp
       do i=1,ix
        do j=1,iy
         sz(i,j,l)=sg1(i,j,iz,L)  ! set initial as top boundary  condition
        enddo
       enddo
       call INTERP_IOAPI('TOPBND',sname(L,1),                ! Load top boundary condition 
     1    idate(1),idate(2),idate(3),ihr,sz(1,1,L),ix*iy,iflag)       
       if(iflag.eq.0) then
		print*,'load top boundary condition for ',
     1   sname(L,1)
        sz(1:ix,1:iy,L)=sz(1:ix,1:iy,L)*sg1(1:ix,1:iy,iz,iair)/1e9   ! PPb to molecular/cm3
	endif
      enddo
      print *, 'TOPBND is done' 
c-------------------------------------------------------------------
      endif
      return
      end
      
      
c***********************************************************************
      subroutine aq_open(numl,year,month,day,hour,sigmaz,dht,iz)
c***********************************************************************
      include 'PARMS3.EXT'      ! i/o API
      include 'FDESC3.EXT'      ! i/o API
      include 'IODECL3.EXT'     ! i/o API

      include 'aqmax.param'
      include 'aqcont.cmm'
      include 'aqindx.cmm'
      include 'aqrxn.cmm'
      dimension numl(3,4),sigmaz(1)
      character*16 ouname(mxspg),blank,sunit(mxspg),outjname(mxspg),
     1  outaeronam(mxspg)
      character*80 aqrst,aqout
      integer aqspout,year,month,day,hour,julb,aeroindex
      common /aqodx/aqspout(mxspg),noutsp,izout,joutindex(mxspg),
     1 joutsp,jzout,aeroindex(mxspg),nout_aero,izaero,outaeronam

      include 'aqsymb.cmm'

      namelist /aqopenf/ouname,AQRST,AQOUT,izout,iscrat,outjname,
     1 jzout,jprnt,                     ! J-value output filename, Zlevel and timestep
     2 outaeronam,izaero, iaeroprnt     ! Aerosol output filename, Zlevel and timestep

c
      call aq_blank(16*mxspg,ouname)
      call aq_blank(16*mxspg,outjname)
      call aq_blank(16*mxspg,outaeronam)
      call aq_blank(16,blank)
c
      open(11,file='aqms.mif',status='old')
      read(11,aqopenf)
      close(11)
c
      call aq_find(mxspg,blank,ouname,lpsec,iflag)    ! find output gas-phase species
      noutsp=lpsec-1
      do i=1,noutsp
      call aq_find(numl(1,3),ouname(i),sname(1,1),lpsec,iflag)
      if(iflag.eq.1) then
	 write(6,*) '** critical error in aqodx in aqms.mif **'
	 write(6,*) '** can not find :',ouname(i)
	 stop
      else
	 aqspout(i)=lpsec   ! output species index
      endif
      enddo

      call aq_find(mxspg,blank,outjname,jpsec,iflag)   !  Jvalue output
      joutsp=jpsec-1
      do i=1,joutsp
      call aq_find(npht+6,outjname(i),jvname,jpsec,iflag)
      if(iflag.eq.1) then
	 write(6,*) '** critical error in aqodx in aqms.mif **'
	 write(6,*) '** can not find :',outjname(i)
	 stop
      else
	 joutindex(i)=jpsec   ! output species index
      endif
      enddo

      call aq_find(mxspg,blank,outaeronam,lpsec,iflag)   ! aerosol   
      nout_aero=lpsec-1
      do i=1,nout_aero
      call aq_find(numl(1,3),outaeronam(i),sname(1,1),lpsec,iflag)
      if(iflag.eq.1) then      
        call aq_find(6,outaeronam(i),extname,lpsec,iflag)    ! search extinction fact
	if(iflage.eq.1) then 
	 write(6,*) '** critical error in aqodx in aqms.mif **'
	 write(6,*) '** can not find :',outaeronam(i)
	 stop
	else
	 aeroindex(i)=lpsec+jaoedust-1
	endif 
      else
	 aeroindex(i)=lpsec   ! output species index
      endif
      enddo

c
      io_log=init3()
      call open_ioapi('DOMAIN')
      call open_ioapi('DOBSON') ! ozone dobson
      call open_ioapi('EMISSION')
      call open_ioapi('EMDAILY')
      call open_ioapi('EMHOURLY')
      call open_ioapi('BIOGENIC') ! biogenic emissions
      call open_ioapi('METEO3D')
      call open_ioapi('METEO2D')
      call open_ioapi('INITF')
      call open_ioapi('BDF')
      call open_ioapi('BDFV')  ! time-varied boundary condition
      call open_ioapi('DEPVEL')
      call open_ioapi('TOPBND')

c      if(.not.open3('DOMAIN',FSREAD3,'aq_open')) then
c        print*, 'failed to open TOPO'
c        stop
c       endif
c      if(.not.open3('EMAREA',FSREAD3,'aq_open')) then
c        print*, 'failed to open EMAREA'
c        stop
c       endif
c      if(.not.open3('INITF',FSREAD3,'aq_open')) then
c        print*, 'failed to open INITF'
c        stop
c       endif
c      if(.not.open3('BDF',FSREAD3,'aq_open')) then
c        print*, 'failed to open BDF'
c        stop
c       endif        
c      if(.not.open3('DEPVEL',FSREAD3,'aq_open')) then
c        print*, 'failed to open DEPVEL'
c        stop
c       endif
c      if(.not.open3('METEO3D',FSREAD3,'aq_open')) then
c        print*, 'failed to open METEO3D'
c        stop
c       endif
c       if (.not. DESC3('METEO3D') ) then   ! get grid information from meteorological 3d file to fill the description of 3d chemical outputc
c         print*, 'Error getting info from METEO3D in aq_open' 
c         stop
c       endif

c---------------------------------------------------------------------------------
cc                                Create Out Put File
      if(unit_out.eq.0) then
	 do i=1,numl(1,3)
         sunit(i)='molecules/cm3'
	 enddo
      else if(unit_out.eq.4) then
	 do i=1,numl(1,3)
	 sunit(i)='ppbv'
	 enddo
      else if(unit_out.eq.2) then
	 do i=1,numl(1,3)
	 sunit(i)='microgram/m3'
	 enddo
      else
	 write(6,*) '** wrong unit_out **'
	 stop
      endif

c       julb = JULIAN (year, month, day)
c       sdate3d = 1000 * year  + julb     ! file start date YYYYDDD
c       stime3d = 10000 * hour            ! file start time HHMMSS
c       tstep3d = 10000 * iscrat           ! file time step HHMMSS

c       ...file description and history

c       do l = 1,MXDESC3
c         fdesc3d(l) = ' '
c       enddo
c       fdesc3d(1) = 'Generated by program AQMS'

c       ... set variables, units and descriptions

c       nvars3d = numl(1,2)
c       do iv = 1,nvars3d
c         vname3d(iv) = sname(iv)
c         units3d(iv) = sunit(iv)
c       enddo

c       do iv = 1,nvars3d
c         vdesc3d(iv) = 'Species Concentration'	! text-descriptions
c         vtype3d(iv) = M3REAL	! basic data types
c       enddo

C----Restart File

c       nlays3d = iz
c       print*,' open restart file'
c       if (.not.OPEN3('AQRST', FSUNKN3, 'STEM')) then
c         print*,' Error Open AQRST'
c 	stop
c       endif

      call create_out_ioapi("AQRST","GRIDSYS",iz,2,sigmaz,dht,
     1     year,month,day,hour,iscrat,numl(1,2),sname,sunit)      ! scratch file
c      write(0,*)   'successful generate restart file'
cc 

C------Output file
c       nvars3d = noutsp
c       do iv = 1,nvars3d
c        vname3d(iv) = ouname(iv)
c       enddo
c       nlays3d=izout
       
c       if (.not.OPEN3('AQOUT', FSUNKN3, subname)) then
c        print*,' Error Open AQOUT'
c	stop
c       endif

       call create_out_ioapi_nest("AQOUT","GRIDSYS",izout,2,sigmaz,dht,
     1     year,month,day,hour,iprnt,noutsp,ouname,sunit)      ! output gas concentration files


       ! Checkpoint level 1 file
       call create_out_ioapi("AQCHKP1","GRIDSYS",iz,2,sigmaz,dht,
     1     year,month,day,hour,1,numl(1,3),sname,sunit)   


       do i=1,joutsp
	 sunit(i)='1/s'
       enddo
       call create_out_ioapi("JOUT","GRIDSYS",jzout,2,sigmaz,dht,
     1     year,month,day,hour,jprnt,joutsp,outjname,sunit)    ! J-value and extinction file
c       write(0,*)   'successful generate JVOUT'
      
      if(unit_aero.eq.0) then             ! determine aerosol output unit
	 do i=1,nout_aero
         sunit(i)='molecules/cm3'
	 enddo
      else if(unit_aero.eq.4) then
	 do i=1,nout_aero
	 sunit(i)='ppbv'
	 enddo
      else if(unit_aero.eq.2) then
	 do i=1,nout_aero
	 sunit(i)='microgram/m3'
	 enddo
      else
	 write(6,*) '** wrong unit_out **'
	 stop
      endif
      do i=1,nout_aero
       if(index(outaeronam(i),'AOE').gt.0) sunit(i)=' 1/km '  ! extinction coefficient
      enddo 
      
c      print*,'outaeronam=',outaeronam
c      print*,'sigmaz=',sigmaz
c      print*,'dht, izaero,iaeroprnt, nout_aero=',dht, izaero,iaeroprnt, 
c     1 nout_aero
c       print*,' aeroindex =',aeroindex(1:nout_aero)
      
      call create_out_ioapi("AEROOUT","GRIDSYS",izaero,2,sigmaz,dht,
     1     year,month,day,hour,iaeroprnt,nout_aero,outaeronam,sunit)    ! aerosol file
   
c      write(0,*)   'successful generate AEROOUT'
      call close_ioap      
c      write(0,*)   'end of aq_open'      
      return
      end
c==============================================================================
c AQMS I/O API module
c==============================================================================
      subroutine OPEN_IOAPI(lname) 

      implicit none

      include 'PARMS3.EXT'      ! i/o API
      include 'FDESC3.EXT'      ! i/o API
      include 'IODECL3.EXT'     ! i/o API
      character*(*) lname
      character*11 progname
      character*256 domainfile
      character*80 msg3d,date3d,time3d
      integer io_log


c      io_log = INIT3()           ! start up I/O API


      if (.not. OPEN3(lname, FSREAD3, progname) ) then
	  msg3d = 'Error opening ' // domainfile
          call M3EXIT (progname, date3d, time3d, msg3d, 1)
      endif
      return
      end
c==============================================================================
      subroutine OPEN_IOAPW(lname) 
c------------------------------------------------------------------------------
      implicit none

      include 'PARMS3.EXT'      ! i/o API
      include 'FDESC3.EXT'      ! i/o API
      include 'IODECL3.EXT'     ! i/o API
      character*(*) lname
      character*11 progname
      character*256 domainfile
      character*80 msg3d,date3d,time3d
      integer io_log


      io_log = INIT3()           ! start up I/O API


      if (.not. OPEN3(lname, FSRDWR3, progname) ) then
	  msg3d = 'Error opening ' // domainfile
          call M3EXIT (progname, date3d, time3d, msg3d, 1)
      endif
      return
      end
      
c*****************************************************************************
      subroutine READ_IOAPI
     +  (lname, varname, year, month, day, hour, field, iflag)
c------------------------------------------------------------------------------
c G. Calori, 1.11.99
c
c LAST REV:
c
c PURPOSE: Read a field from an AQMS input file
c          (EDSS/Models-3 I/O API format)
c
c PRECONDITIONS: 
c Following env vars need to be set: 
c <lname>	logical name of input file
c
c INPUT:
c <lname>		C  logical name of output file
c varname	     C*16  name of variable to be read
c year, month, day	I  year (yyyy), month, day
c hour			I  hour
c 
c OUTPUT:
c field			R  field just read
c
c CALLS: I/O API library
c
c NOTES: If 'varname' does not exists at specified time, 
c        'field' is returned unchanged
c------------------------------------------------------------------------------
      implicit none

      include 'aqms.param'
      include 'PARMS3.EXT'	! i/o API
      include 'FDESC3.EXT'	! i/o API
      include 'IODECL3.EXT'	! i/o API

      character*(*) lname
      character*(*) varname
      integer day, month, year, hour
      real field(1),work(imother,jmother,izm)

      integer trimlen, julian

      integer date3d, time3d, jul3d
      integer ios,iflag,i,j,k
      character*256 filename
      character*18 subname
      character*80 msg3d

      data subname /'read_ioapi'/


      iflag=0
      jul3d = JULIAN (year, month, day)
      date3d = 1000 * year + jul3d		! current date YYYYDDD
      time3d = 10000 * hour			! current time HHMMSS

      
c      write(0,*) 'read variable ',varname,date3d,time3d,' from ',lname
      if (.not.
     +    CHECK3 (TRIM(lname), TRIM(varname),
     +            date3d, time3d)
     +   ) then
	iflag=1
	write(6,*)'Warning: Can not Read the variable ',varname,lname
	write(6,*)'time =', date3d, time3d
        return
      endif

      if (.not. DESC3(trim(lname)) ) then   
       print*,'No information for',lname
       stop
      endif 
      
      if(imother.eq.ncols3d.and.jmother.eq.nrows3d) then         ! mother domain
       if(.not.read3(trim(lname),trim(varname),ALLAYS3,date3d,time3d, 
     +   field)) then
        write(6,*) 'Error reading var ' //TRIM(varname)//
     +    ' from file ' // TRIM(lname) // 'at time ',
     +    date3d,time3d  
	stop
       endif 	
c       if(nlays3d.eq.1) then
c	do j=1,iym
c         do i=1,ixm
c	 field(i+(j-1)*ixm)=work(i+ioff,j+joff,1)
c	 enddo
c	enddo
c       else
c        do k=1,nlays3d
c 	 do j=1,iym
c          do i=1,ixm
c	  field(i+((j-1)+(k-1)*iym)*ixm)=work(i+ioff,j+joff,k)
c	  enddo
c	 enddo
c	enddo 
c       endif
       return 
      endif

      if(ixm.ne.ncols3d.or.iym.ne.nrows3d) then   ! check dimension
       print*,'dimension does not match ',lname
       print*,ixm,iym,ncols3d,nrows3d
       stop
      endif
       
      if (.not.
     +      READ3 (TRIM(lname), 
     +             TRIM(varname),
     +             ALLAYS3, date3d, time3d, field)
     +     ) then
          
        write(6,*) 'Error reading var ' // TRIM(varname)//
     +    ' from file ' // TRIM(lname) // 'at time ',
     +    date3d,time3d  
c          call ENVSTR (lname(:TRIMLEN(lname)), 
c     +                 'AQMS input file', 'dummy_in.nc', filename, ios)
c          msg3d = 'Error reading var ' // varname(:TRIMLEN(varname)) //
c     +      ' from file ' // filename(:TRIMLEN(filename))
c          call M3EXIT (subname, date3d, time3d, msg3d, 1)
          stop
        endif
      
      return
      end


      subroutine INTERP_IOAPI
     +  (lname, varname, year, month, day, hour, field,  nsize, iflag)
c------------------------------------------------------------------------------
c Y. Tang, 1.11.99
c
c LAST REV:
c
c PURPOSE: Read a field from an AQMS input file
c          (EDSS/Models-3 I/O API format)
c
c PRECONDITIONS: 
c Following env vars need to be set: 
c <lname>	logical name of input file
c
c INPUT:
c <lname>		C  logical name of output file
c varname	     C*16  name of variable to be read
c year, month, day	I  year (yyyy), month, day
c hour			I  hour
C nsize                 I  buffer size for storing data
c 
c OUTPUT:
c field			R  field just read
c
c CALLS: I/O API library
c
c NOTES: If 'varname' does not exists at specified time, 
c        'field' is returned unchanged
c------------------------------------------------------------------------------
      implicit none

      include 'aqms.param'
      include 'PARMS3.EXT'	! i/o API
      include 'FDESC3.EXT'	! i/o API
      include 'IODECL3.EXT'	! i/o API

      character*(*) lname
      character*(*) varname
      integer day, month, year, hour
      real field(1),work(imother,jmother,izm)

      integer trimlen, julian

      integer date3d, time3d, jul3d
      integer ios,iflag,nsize,i,j,k,L
      character*256 filename
      character*18 subname
      character*80 msg3d

      data subname /'interp_ioapi'/

      iflag=0
      jul3d = JULIAN (year, month, day)
      date3d = 1000 * year + jul3d		! current date YYYYDDD
      time3d = 10000 * hour			! current time HHMMSS

      if (.not. DESC3(TRIM(lname))) stop   
      do L=1,nvars3d
       if(vname3d(L).eq.trim(varname)) goto 10   ! find this variable
      enddo
      iflag=1 
      return               ! if there is no such a variable, return

 10   if(imother.eq.ncols3d.and.jmother.eq.nrows3d) then         ! mother domain
       if(.not.interp3(trim(lname),trim(varname),subname,date3d,time3d,
     +   ncols3d*nrows3d*nlays3d,field)) then
        write(6,*) 'Error interping var ' //TRIM(varname)//
     +    ' from file ' // TRIM(filename) // 'at time ',
     +    date3d,time3d  
	stop
       endif 	
c       if(nlays3d.eq.1) then
c	do j=1,iym
c         do i=1,ixm
c	 field(i+(j-1)*ixm)=work(i+ioff,j+joff,1)
c	 enddo
c	enddo
c       else
c        do k=1,nlays3d
c 	 do j=1,iym
c          do i=1,ixm
c	  field(i+((j-1)+(k-1)*iym)*ixm)=work(i+ioff,j+joff,k)
c	  enddo
c	 enddo
c	enddo 
c       endif
       return 
      endif

      if(ixm.ne.ncols3d.or.iym.ne.nrows3d) then   ! check dimension
       print*,'dimension does not match ',lname
       print*,ixm,iym,ncols3d,nrows3d
       stop
      endif
        
      if (.not. INTERP3(TRIM(lname),
     1	TRIM(varname), subname,
     2  date3d, time3d,nsize, field)) then
         print*, 'Error interping var '//TRIM(varname) //
     +      ' from file ' //trim(lname)
         print*,'date3d,time3d=',date3d,time3d
        stop
      endif
      
      return
      end




      subroutine CREATE_OUT_IOAPI 
     +  (loutname, loutgrid, nz, vertype, zvect, ztop,
     +   yearb, monthb, dayb, hourb, dt,
     +   nvar, varnames, varunits)
c------------------------------------------------------------------------------
c G. Calori, 1.11.99
c
c LAST REV:
c
c PURPOSE: Create/open AQMS 3D output files (EDSS/Models-3 I/O API format)
c
c PRECONDITIONS: 
c Following env vars need to be set: 
c <loutname>	logical name of output file to be created
c COORDSYS	name of coordinate system
c <loutgrid>	logical name of grid system adopted by output file
c
c INPUT:
c loutname		C  logical name of file to be created
c loutgrid		C  logical name of grid system adopted by output file
c nz			I  actual # of vertical grid points
c vertype		I  vertical coordinates system:
c                          1 = terrain-following; 2 = sigma-z
c zvect			R  vector of vertical coordinates
c			   (m above ground, if terrain-following;
c			   0-1 numbers, if sigma-z)
c ztop			R  top of model domain (m above m.s.l.)
c                          (used just in case of terrain-following)
c yearb, month, dayb 	I  starting year (yyyy), month, day
c hourb			I  starting hour
c dt			I  time step (hr)
c nvar			I  # of variables that the file will contain
c varnames	     C*16  list of variables names 
c varunits	     C*16  list of variables units
c
c OUTPUT:
c <loutname> file is created/opened
c 
c CALLS: I/O API library
c------------------------------------------------------------------------------
      implicit none

      include 'PARMS3.EXT'	! i/o API
      include 'FDESC3.EXT'	! i/o API
      include 'IODECL3.EXT'	! i/o API
      	
      character*(*) loutname, loutgrid
      integer nz, vertype
      integer dayb, monthb, yearb, hourb, dt
      real zvect(1), ztop
      integer nvar
      character*16 varnames(1), varunits(1)

      integer trimlen, julian
      logical dscoord, dscgrid

      integer io_msg
      integer date3d, time3d, julb
      integer k, l, iv, ios
      character*16 coordname, gridname
      character*18 subname
      character*80 msg3d

      data io_msg /6/
      data subname /'create_out_ioapi'/



c      io_log = INIT3()           ! start up I/O API

c       get filename, coordinates system and grid name from environment

      if (.not. DESC3('METEO3D') ) then   ! get grid information from meteorological 3d file to fill the description of 3d chemical output
        print*, 'Error getting info from METEO3D in create_out_ioapi' 
        stop
      endif

c       ...set time step structure

      julb = JULIAN (yearb, monthb, dayb)
      sdate3d = 1000 * yearb + julb     ! file start date YYYYDDD
      stime3d = 10000 * hourb           ! file start time HHMMSS
      tstep3d = 10000 * dt              ! file time step HHMMSS

c       ...file description and history

      do l = 1,MXDESC3
        fdesc3d(l) = ' '
      enddo
      fdesc3d(1) = 'Generated by program AQMS'

c       ... vertical structure

      nlays3d = nz

c       ... set variables, units and descriptions

      nvars3d = nvar
      do iv = 1,nvar
        vname3d(iv) = varnames(iv)
        units3d(iv) = varunits(iv)
      enddo

      do iv = 1,nvars3d
        vdesc3d(iv) = 'Species Concentration'	! text-descriptions
        vtype3d(iv) = M3REAL	! basic data types
      enddo

c       open file as "unknown": if it does not exist, create it;
c       else check header against description supplied in FDESC3.EXT
c       open for output in any case


      write(io_msg,'(/,a,a)') 
     +  'Opening/creating file : ' , loutname(:TRIMLEN(loutname))
      write(io_msg,'(a,a)') 
     +  'Coordinates system: ' , coordname(:TRIMLEN(coordname))
      write(io_msg,'(a,a)') 
     +  'Grid system       : ' , gridname(:TRIMLEN(gridname))

      if (.not. 
     +    OPEN3(loutname(:TRIMLEN(loutname)), FSUNKN3, subname)
     +   ) then
       write(*,*)'Error opening ' // loutname(:TRIMLEN(loutname))
c        msg3d = 'Error opening ' // loutname(:TRIMLEN(loutname))
c        call M3EXIT (subname, date3d, time3d, msg3d, 1)
	stop
      endif
      write(io_msg,*)'opened IOAPI file: '//loutname(:TRIMLEN(loutname))
      
      return
      end






      subroutine WRITE_OUT_IOAPI
     +  (loutname, year, month, day, hour, varname, field)
c------------------------------------------------------------------------------
c G. Calori, 1.11.99
c
c LAST REV:
c
c PURPOSE: Write a field to an AQMS output file
c          (EDSS/Models-3 I/O API format)
c
c PRECONDITIONS: 
c 'create_out_ioapi' must has been previously called
c
c INPUT:
c <loutname>		C  logical name of output file
c year, month, day	I  current year (yyyy), month, day
c hour			I  current hour
c varname	     C*16  name of variable to be written
c field(nwords)		R  field to be written
c 
c OUTPUT:
c on <loutname> file 
c
c CALLS: I/O API library
c------------------------------------------------------------------------------
      implicit none

c      include 'netcdf.inc'
      include 'PARMS3.EXT'	! i/o API
      include 'FDESC3.EXT'	! i/o API
      include 'IODECL3.EXT'	! i/o API

      character*(*) loutname
      integer day, month, year, hour
      character*16 varname
      real field(1)
      
      integer julian, trimlen

      integer io_msg, ios
      integer date3d, time3d, jul3d
      character*256 outfile
      character*17 subname
      character*80 msg3d

      data io_msg /6/
      data subname /'write_out_ioapi'/

c	convert to i/o api time

      jul3d = JULIAN (year, month, day)
      date3d = 1000 * year + jul3d    ! file current date YYYYDDD
      time3d = 10000 * hour           ! file current time HHMMSS
      
      if(time3d.eq.240000) then
	time3d = 0
	date3d = date3d + 1
      end if
      
c	write field
      if (.not. 
     +    WRITE3(loutname(:TRIMLEN(loutname)),
     +           varname, date3d, time3d, field)
     +   ) then
        call ENVSTR (loutname(:TRIMLEN(loutname)),
     +               'AQMS output file', 'dummy_out.nc',
     +               outfile, ios)
        msg3d = 'Error writing var ' // varname
c     +     //  ' at date&time ', date3d, time3d,
c     +    ' on AQMS output file ' // outfile
        call M3EXIT (subname, date3d, time3d, msg3d, 1)
        stop
      endif

      return
      end
c*************************************************************************
      subroutine READ_IOAPI_BND
     +  (varname, year, month, day, hour, 
     +   nx, ny, nz, south, east, north, west, scratch)
c------------------------------------------------------------------------------
c G. Calori, 8.11.99
c
c LAST REV:
c
c PURPOSE: Read a set of lateral b.c. at a given time and for a given species
c          from an AQMS lateral b.c. file (EDSS/Models-3 I/O API format)
c
c PRECONDITIONS: 
c lateral b.c. file (logical name 'BDF') file must has been already opened
c
c INPUT:
c varname	   	     C*16  name of variable to be read
c year, month, day		I  desired year (yyyy), month, day
c hour				I  desired hour
c nx, ny, nz			I  actual dimension of 3D grid
c scratch(2*nx+2*ny+4,nz)	R  scratch area 
c 
c OUTPUT:
c south(nx,nz), north(nx,nz)	R  S and N boundary conditions
c east(ny,nz), west(ny,nz)	R  E and W boundary conditions
c
c CALLS: I/O API library
c
c NOTES: If 'varname' does not exists at specified time, 
c        'south, east, north, west' are returned unchanged
c------------------------------------------------------------------------------
      implicit none

c      include 'netcdf.inc'
      include 'PARMS3.EXT'	! i/o API
      include 'FDESC3.EXT'	! i/o API
      include 'IODECL3.EXT'	! i/o API

      character*16 varname
      integer day, month, year, hour
      integer nx, ny, nz
      real south(nx,nz), east(ny,nz), north(nx,nz), west(ny,nz), 
     +     scratch(2*nx+2*ny+4,nz)

      integer trimlen, julian

      integer date3d, time3d, jul3d, ibtime,ietime,inowtime
      integer i, j, k, L, i0n, j0e, j0w
      integer ios
      character*256 bcfile
      character*18 subname
      character*80 msg3d
      logical nflag,layer20

      data subname /'read_ioapi_bnd'/

      jul3d = JULIAN (year, month, day)
      date3d = 1000 * year + jul3d		! current date YYYYDDD
      time3d = 10000 * hour			! current time HHMMSS

      if (.not. DESC3('BDFV') ) goto 20    ! no time-varied boundary condition
      if (nx.ne.ncols3d.or.ny.ne.nrows3d.or.nz.lt.nlays3d.or.
     1  ftype3d.ne.bndary3) then  ! allow nz.ge.nlay3d in case 20 layer input for 21 layer stem
       print*,'Time-varied Boundary file Wrong !',nx,ncols3d,ny,nrows3d,
     &  nz,nlays3d,ftype3d,bndary3
       print*,'Checking your BDFV setting'
       stop 
      endif

      if(nz.gt.nlays3d) then
       if(nz.eq.(nlays3d+1)) then       ! 20 layer BDFV
        layer20=.true.
       else
        layer20=.false.
       endif
      endif


      do L=1,nvars3d
       if(vname3d(L).eq.varname) goto 10   ! find this variable
      enddo
      layer20=.false.
      goto 20

 10   ibtime=sdate3d*100+stime3d/10000        ! begin time of the file in YYMMDDHH
      ietime=(mxrec3d*tstep3d+stime3d)/10000
      ietime=(sdate3d+ietime/24)*100+mod(ietime,24) ! end time of the file in YYMMDDHH
      inowtime=date3d*100+time3d/10000              ! nowtime in YYMMDDHH

      if(inowtime.ge.ibtime.and.inowtime.le.ietime) then  ! find time range

       if(interp3('BDFV',varname(:TRIMLEN(varname)),
     +    subname, date3d, time3d, (2*nx+2*ny+4)*nlays3d,scratch)) then
         goto 30
	else
          Print*, 'Error interping var '// varname(:TRIMLEN(varname))//
     +      ' from IOAPI file BDFV'

          stop
        endif
      endif 	
           
 20   if (.not. INTERP3 ('BDF', varname(:TRIMLEN(varname)),
     +    subname, date3d, time3d, (2*nx+2*ny+4)*nlays3d,scratch)) then
         Print*, 'Error interping var '// varname(:TRIMLEN(varname))//
     +      ' from IOAPI file BDF'
        print*,'date3d,time3d=',date3d,time3d
        stop      
      endif

 30   if(layer20) then                 ! apply 20 layers' lowest layer data to current 1&2 layers
                                                                                                      
        do k=nz,2,-1
        scratch(1:(2*nx+2*ny+4),k)=scratch(1:(2*nx+2*ny+4),k-1)
        enddo
      endif

      i0n = nx + ny + 2
      do k = 1,nz
        do i = 1,nx
          south(i,k) = scratch(i,k)
          north(i,k) = scratch(i0n+i,k)
        enddo
      enddo
                        
      j0e = nx + 1
      j0w = 2*nx + ny + 3
      do k = 1,nz
        do j = 1,ny
          east(j,k) = scratch(j0e+j,k)
          west(j,k) = scratch(j0w+j,k)
        enddo
      enddo
            
      return
      end


      subroutine tuvclouds(iz,z,pbl,p,prate,t,vapor,cw,rw,cldod,ccover,
     1 ktop,wetk)
C-----------------------------------------------------------------
C     compute the Jcorrecot value due to cloud
C     Input:
C      iz       demension
C      Z        model grid height above sea level (m)
C      PBL      pbl height above sea level (m)
C      P        Pressure   (Pa)
C      PRATE    Precipitation rate (mm/hr)
C      T        Temperature (k)
c      vapor    water vapor (Kg/Kg) 
C      cw       Cloud Water Content (Kg/Kg)
C      rw       Rain Water Content (Kg/Kg)
C
C     Output:
C      cldod    Cloud optical depth
C      ccover   cloud coverage
C      Ktop     index of clound top height
C      wetk     liquid removing factor for SO2, SO4, H2O2 and HNO3
C
C   Author: Youhua Tang
C-----------------------------------------------------------------     
      parameter(CWMIN=1e-6,   ! define if there is cloud 
     2  prmin=0.01, nwet=4 )          ! define if there is precipitation
      integer iz,ktop
      real z(iz),pbl,p(iz),prate,t(iz),vapor(iz),cw(iz),rw(iz),
     1 cldod(iz),ccover(iz), wetk(iz,nwet), iradius

      data rdry,cradius,iradius, rradius/287.04, 1.e-5, 9.e-5, 1.e-3/
      ! air constant, cloud water drop, ice drop and rain drop radius in meter

      real c303,c302
      parameter(C303=19.83,C302=5417.4)
      
      ESAT(TEMK)=.611*EXP(C303-C302/TEMK)       ! for calculating saturated water vapor pressure  
      QSAT(ESAT1,PCB)=ESAT1*.622/(PCB-ESAT1)    ! TEMK is ambient temperature in K, PCB is the pressue in KPa
                                                ! QSAT is the saturated humidity in kg/kg

      do k=1,iz 
        cldod(k)=0. 
	ccover(k)=0.
	do L=1,4
	 wetk(k,L)=0.
	enddo 
      enddo 	

      cover_max=0.
      do k=1,iz
       if(cover_max.lt.cw(k)) then
        cover_max=cw(k)
	kcover=k
       endif
      enddo
      
      if(cover_max.ge.cwmin) then  ! cloud exist
        do k=kcover,iz
	 if(cw(k).lt.cwmin) goto 20
	enddo
 20     ktop=k	    
    
       do k=1, ktop
        rh=vapor(k)/QSAT(ESAT(         ! computing relative humudity
     1		t(k)),p(k)/1000)         !convert to KPa
        if(z(k).lt. pbl) then        ! within Convective Boundary
	 RHC=0.98                           ! Cloud relative humididty
	 if(rh.gt.rhc) then
	  ccover(k)=0.34 *(RH - RHC)/(1. - RHC) ! SCHUMANN 89, AND WYNGAARD AND BROST 84
	 else
	  ccover(k)=0.
	 endif
	else  
	 SG1= P(K)/P(1)
         RHC= 1. - 2.*SG1*(1.-SG1)*(1+1.732*(SG1-.5))
         IF(RH.GT.RHC) THEN
           CCOVER(K)= ((RH - RHC)/(1. - RHC))**2  ! Geleyn et al 82
         ELSE
          CCOVER(K) = 0.0
         END IF
	endif 
	ccover(k)=amin1(amax1(ccover(k),0.),1.)        ! cloud coverage
       enddo	
	
       do k=ktop-1,1,-1
         ccover(k)=1-(1.-ccover(k+1))*(1.-ccover(k))	! cloud total coverage profile
       enddo
       
       if(prate.gt.prmin) ccover(1:ktop)=0.9     ! while precipitation

c  o.d. = 3 L dz / [ 2 rho r ]    for water cloud
c
c where 
c L = mean condensed water content, kg m-3, L= cw*airdensity+rw*airdensity
c dz = mean depth of cloudy layer, m
c rho = density of water  1000 kg m-3
c r = drop radius, 10 microns (1e-5 meters) is a good average.
c
C  ice cloud: o.d.= L (ai+bi/re) dz/ rho   (Ebert JGR 97(D4) 3831)
C  where
c  L = mean condensed water content, kg m-3, L= cw*airdensity+rw*airdensity
c  ai = 3.448 m2/kg                         for all wavelengths 
c  bi = 2.431e+3 um*m2/kg = 2.431e-3 m3/kg  for all wavelengths
c  re: effective ice radius
       
       do k=1,iz-1
        airdensity=(p(k)/t(k)+p(k+1)/t(k+1))/rdry/2            ! kg/m3 air density
	if((t(k)+t(k+1))/2.ge.273.15) then ! water cloud
         cldod(k)=1.5*((rw(k)+rw(k+1))/rradius+(cw(k)+cw(k+1))/cradius)
     1	 *airdensity*(z(k+1)-z(k))/1e3/2
        else
	 cldod(k)= (rw(k)+cw(k)+rw(k+1)+cw(k+1))/2*airdensity
     1	  *(3.448+2.431e-3/iradius)*(z(k+1)-z(k))/850
        endif
       enddo
             
       do k=1,ktop
        wetk(k,1)= 2e-5*prate                 ! so2
	wetk(k,2)= 5e-5*prate**0.88           ! so4
	wetk(k,3)= wetk(k,1)*10.              ! H2O2
	wetk(k,4)= wetk(k,1)*10.              ! HNO3
       enddo
        
c       if(ktop+2.le.iz) then
c        do k=ktop+2,iz
c	 jcorrect(k)=1.     ! clear Sky above cloud
c	enddo
c       endif
c       jcorrect(ktop+1)=1.3  ! albedo effect 
c       do k=1,ktop
c        jcorrect(k)=1.-0.55*1.75**ccover(k)
c       enddo

c      else 
c        do k=1,iz
c	 jcorrect(k)=1.     ! clear Sky 
c	enddo
	ktop=0
      endif
      end	




      subroutine CREATE_OUT_IOAPI_NEST
     +  (loutname, loutgrid, nz, vertype, zvect, ztop,
     +   yearb, monthb, dayb, hourb, dt,
     +   nvar, varnames, varunits)
c------------------------------------------------------------------------------
c G. Calori, 1.11.99
c
c LAST REV:
c
c PURPOSE: Create/open AQMS 3D output files (EDSS/Models-3 I/O API format)
c
c PRECONDITIONS: 
c Following env vars need to be set: 
c <loutname>	logical name of output file to be created
c COORDSYS	name of coordinate system
c <loutgrid>	logical name of grid system adopted by output file
c
c INPUT:
c loutname		C  logical name of file to be created
c loutgrid		C  logical name of grid system adopted by output file
c nz			I  actual # of vertical grid points
c vertype		I  vertical coordinates system:
c                          1 = terrain-following; 2 = sigma-z
c zvect			R  vector of vertical coordinates
c			   (m above ground, if terrain-following;
c			   0-1 numbers, if sigma-z)
c ztop			R  top of model domain (m above m.s.l.)
c                          (used just in case of terrain-following)
c yearb, month, dayb 	I  starting year (yyyy), month, day
c hourb			I  starting hour
c dt			I  time step (hr)
c nvar			I  # of variables that the file will contain
c varnames	     C*16  list of variables names 
c varunits	     C*16  list of variables units
c
c OUTPUT:
c <loutname> file is created/opened
c 
c CALLS: I/O API library
c------------------------------------------------------------------------------
      implicit none

	include 'aqms.param'
      include 'PARMS3.EXT'	! i/o API
      include 'FDESC3.EXT'	! i/o API
      include 'IODECL3.EXT'	! i/o API
      	
      character*(*) loutname, loutgrid
      integer nz, vertype
      integer dayb, monthb, yearb, hourb, dt
      real zvect(1), ztop
      integer nvar
      character*16 varnames(1), varunits(1)

      integer trimlen, julian
      logical dscoord, dscgrid

      integer io_msg
      integer date3d, time3d, julb
      integer k, l, iv, ios
      character*16 coordname, gridname
      character*18 subname
      character*80 msg3d

      data io_msg /6/
      data subname /'create_out_ioapi'/



c      io_log = INIT3()           ! start up I/O API

c       get filename, coordinates system and grid name from environment

      if (.not. DESC3('METEO3D') ) then   ! get grid information from meteorological 3d file to fill the description of 3d chemical output
        print*, 'Error getting info from METEO3D in create_out_ioapi' 
        stop
      endif

	ncols3d = ixm
	nrows3d = iym
c       ...set time step structure

      julb = JULIAN (yearb, monthb, dayb)
      sdate3d = 1000 * yearb + julb     ! file start date YYYYDDD
      stime3d = 10000 * hourb           ! file start time HHMMSS
      tstep3d = 10000 * dt              ! file time step HHMMSS

c       ...file description and history

      do l = 1,MXDESC3
        fdesc3d(l) = ' '
      enddo
      fdesc3d(1) = 'Generated by program AQMS'

c       ... vertical structure

      nlays3d = nz

c       ... set variables, units and descriptions

      nvars3d = nvar
      do iv = 1,nvar
        vname3d(iv) = varnames(iv)
        units3d(iv) = varunits(iv)
      enddo

      do iv = 1,nvars3d
        vdesc3d(iv) = 'Species Concentration'	! text-descriptions
        vtype3d(iv) = M3REAL	! basic data types
      enddo

c       open file as "unknown": if it does not exist, create it;
c       else check header against description supplied in FDESC3.EXT
c       open for output in any case


      write(io_msg,'(/,a,a)') 
     +  'Opening/creating file : ' , loutname(:TRIMLEN(loutname))
      write(io_msg,'(a,a)') 
     +  'Coordinates system: ' , coordname(:TRIMLEN(coordname))
      write(io_msg,'(a,a)') 
     +  'Grid system       : ' , gridname(:TRIMLEN(gridname))

      if (.not. 
     +    OPEN3(loutname(:TRIMLEN(loutname)), FSUNKN3, subname)
     +   ) then
       write(*,*)'Error opening ' // loutname(:TRIMLEN(loutname))
c        msg3d = 'Error opening ' // loutname(:TRIMLEN(loutname))
c        call M3EXIT (subname, date3d, time3d, msg3d, 1)
	stop
      endif
      write(io_msg,*)'opened IOAPI file: '//loutname(:TRIMLEN(loutname))
      
      return
      end






      subroutine WRITE_OUT_IOAPI_NEST
     +  (loutname, year, month, day, hour, varname, field)
c------------------------------------------------------------------------------
c G. Calori, 1.11.99
c
c LAST REV:
c
c PURPOSE: Write a field to an AQMS output file
c          (EDSS/Models-3 I/O API format)
c
c PRECONDITIONS: 
c 'create_out_ioapi' must has been previously called
c
c INPUT:
c <loutname>		C  logical name of output file
c year, month, day	I  current year (yyyy), month, day
c hour			I  current hour
c varname	     C*16  name of variable to be written
c field(nwords)		R  field to be written
c 
c OUTPUT:
c on <loutname> file 
c
c CALLS: I/O API library
c------------------------------------------------------------------------------
      implicit none

c      include 'netcdf.inc'
      include 'PARMS3.EXT'	! i/o API
      include 'FDESC3.EXT'	! i/o API
      include 'IODECL3.EXT'	! i/o API

      character*(*) loutname
      integer day, month, year, hour
      character*16 varname
      real field(1)
      
      integer julian, trimlen

      integer io_msg, ios
      integer date3d, time3d, jul3d
      character*256 outfile
      character*17 subname
      character*80 msg3d

      data io_msg /6/
      data subname /'write_out_ioapi'/

c	convert to i/o api time

      jul3d = JULIAN (year, month, day)
      date3d = 1000 * year + jul3d    ! file current date YYYYDDD
      time3d = 10000 * hour           ! file current time HHMMSS
      
      if(time3d.eq.240000) then
	time3d = 0
	date3d = date3d + 1
      end if
      
c	write field
      if (.not. 
     +    WRITE3(loutname(:TRIMLEN(loutname)),
     +           varname, date3d, time3d, field)
     +   ) then
        call ENVSTR (loutname(:TRIMLEN(loutname)),
     +               'AQMS output file', 'dummy_out.nc',
     +               outfile, ios)
        msg3d = 'Error writing var ' // varname
c     +     //  ' at date&time ', date3d, time3d,
c     +    ' on AQMS output file ' // outfile
        call M3EXIT (subname, date3d, time3d, msg3d, 1)
        stop
      endif

      return
      end

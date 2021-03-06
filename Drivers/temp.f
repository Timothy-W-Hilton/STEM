      module Names
       ! Names of local checkpoints
         character(len=32) :: fname_chkp2 =
     &"/scratch/Conc_Hg_Chai"
      end module Names

      program aq_driver_function
c****************************************************************************
c     purpose: Setting up calling sequence and Allocate memories.
c******************************************************************************
c---+----1----+----2----+----3----+----4----+----5----+----6----+----7-----
      use StemMemAlloc 
      use HVStemCommunication
      use Names

c--------------------------------------------------------------------------
      include 'aqmax.param'
      include 'aqms.param'
      include 'aqcon1.cmm'
      include 'aqcon2.cmm'
      include 'aqcon5.cmm'
      include 'aqcont.cmm'
      include 'aqfile.cmm'  
      include 'aqrxn.cmm'	
      include 'aqsymb.cmm'
      include 'aqspec.cmm'
      include 'aqindx.cmm'
c--------------------------------------------------------------------------
      character(len=3) :: mode
      character(len=32) :: fname_conc_ini, fname_lambda
      character(len=32) :: fname_obs1, fname_pre1
      integer :: unit_emi_fac = 38, unit_emi_grd = 39, unit_mode = 40
      integer :: unit_cost = 41, unit_obs1 = 42, unit_pred1 = 43
      !obs1,2: DC8 or P3 only here, the other should be added later
      !The format of the observation: f_t[gmt hr],f_x,f_y,f_z,o3[ppb]
c--------------------------------------------------------------------------

      parameter(indep_div=0)   ! distance from lateral boundary for divergence correction 
      parameter(NUM_obs_max=49999, NUM_mea_max=100, NUM_spe_max=50)       
      ! Actual number of records, measurements/record, species/measurement 
      integer :: NUM_obs,NUM_mea
      integer :: NUM_spe(NUM_mea_max)
      ! to be read from data file header
      ! Blind data has simpler format, only one species allowed for each obs 
      !Observation # small, memory saving is not a issue here. 
      real f_t(NUM_obs_max), f_x(NUM_obs_max), 
     &     f_y(NUM_obs_max), f_z(NUM_obs_max),
     &     f_obs(NUM_obs_max,NUM_mea_max), 
     &     f_obs_model(NUM_obs_max,NUM_mea_max)
      integer :: obs_index(NUM_mea_max,NUM_spe_max) 
      integer :: i_flt, i_mea, i_sg1
      real unc_obs(NUM_mea_max),ave_obs(NUM_mea_max)
      real count_valid(NUM_mea_max)  !no need to convert from int to float
c--------------------------------------------------------------------------
      integer :: ix=ixm, iy=iym, iz=izm  ! Grid Dimensions
      integer :: N_gas=iLm               ! No. of gas species
      integer :: N_liquid=iLqm            ! No. of liquid species
      integer :: N_particle=iLptm        ! No. of particulate species
c--------------------------------------------------------------------------
c      dimension sg1(ixm*iym*izm*iLm),sl1(ixm*iym*izm*iLqm)
c      dimension sp1(ixm*iym*izm*ilptm)
      real, dimension(:,:,:,:), pointer :: sg1, sg1_h, sg1_v  ! gas dimension
      real, dimension(:,:,:,:), pointer :: sl1, sl1_h, sl1_v  ! liquid dimension
      real, dimension(:,:,:,:), pointer :: sp1, sp1_h, sp1_v 
c  THE ADJOINT VARIABLES
      real, dimension(:,:,:,:), pointer :: Lambda, Lambda_h, Lambda_v
      real, dimension(:,:,:,:), pointer :: Lambda0, Lambda0_h, Lambda0_v
      real, dimension(:,:,:,:), pointer :: dc_dq, dc_dq_h, dc_dq_v
      real, dimension(:,:,:,:), pointer :: dc_dem, dc_dem_h, dc_dem_v 
      !Change the sequence of the sum
      real, dimension(:,:,:),   pointer :: aird, aird_h, aird_v
c      dimension u(ixm*iym*izm),v(ixm*iym*izm),w(ixm*iym*izm)
      real, dimension(:,:,:), pointer :: u, u_h, u_v
      real, dimension(:,:,:), pointer :: v, v_h, v_v 
      real, dimension(:,:,:), pointer :: w, w_h, w_v
c  dimension kh(ixm*iym*izm),kv(ixm*iym*izm),t(ixm*iym*izm),cldod(ixm*iym*izm),ccover(ixm*iym*izm)
      real, dimension(:,:,:), pointer :: kh, kh_h, kh_v
      real, dimension(:,:,:), pointer :: kv, kv_h, kv_v
      real, dimension(:,:,:), pointer :: t,  t_h,  t_v
      real, dimension(:,:,:), pointer :: cldod, cldod_h, cldod_v
      real, dimension(:,:,:), pointer :: ccover, ccover_h, ccover_v
c      dimension dz(ixm*iym*izm)
      real, dimension(:,:,:), pointer :: dz, dz_h, dz_v
c      dimension wc(ixm*iym*izm),wr2(ixm*iym*izm)
      real, dimension(:,:,:), pointer :: wc, wc_h, wc_v
      real, dimension(:,:,:), pointer :: wr2, wr_h, wr_v
c      dimension sprc(ixm*iym),rvel(ixm*iym*izm)
      real, dimension(:,:),   pointer   :: sprc, sprc_h, sprc_v
      real, dimension(:,:,:), pointer :: rvel, rvel_h, rvel_v
c      dimension sx(iym*izm*2*iLm),sy(ixm*izm*2*iLm),sz(ixm*iym*iLm)            
      real, dimension(:,:,:,:), pointer :: sx, sx_h, sx_v 
      real, dimension(:,:,:,:), pointer :: sy, sy_h, sy_v
      real, dimension(:,:,:),   pointer :: sz, sz_h, sz_v
c      dimension q(ixm*iym*iLm)
      real, dimension(:,:,:),   pointer :: q, q_h, q_v
c      dimension em(ixm*iym*izm*iLm)
      real, dimension(:,:,:,:), pointer :: em, em_h, em_v
c      dimension vg(ixm*iym*iLm),fz(ixm*iym*iLm)
      real, dimension(:,:,:),   pointer :: vg, vg_h, vg_v
      real, dimension(:,:,:),   pointer :: fz, fz_h, fz_v
c      dimension hdz(ixm*iym*izm)
      real, dimension(:,:,:),   pointer :: hdz, hdz_h, hdz_v
c      dimension h(ixm*iym),tlon(ixm*iym),tlat(ixm*iym)
      real, dimension(:,:),     pointer :: h,    h_h,    h_v
      real, dimension(:,:),     pointer :: deltah,deltah_h,deltah_v
      real, dimension(:,:),     pointer :: tlon, tlon_h, tlon_v 
      real, dimension(:,:),     pointer :: tlat, tlat_h, tlat_v
C     dimension kctop(ixm*iym),dobson(ixm*iym)
      real, dimension(:,:),  pointer :: kctop, kctop_h, kctop_v
      real, dimension(:,:),  pointer :: dobson, dobson_h, dobson_v
C      
      real   :: dx(ixm),dy(iym)
      real   :: sigmaz(izm),ave_spec(ilm)
      integer :: iunit(25),iout(25),idate(3)
      real   :: dht, baseh, ut, uut,  dt, dtmax
      integer :: irxng, irxnl, ixtrn, iytrn, iztrn
      integer :: iter, it, num, iend, mdt
      character aline*80
      real :: costfct!,fac_emi,sum_emi
      real, dimension(:,:,:,:), pointer :: emi_fac, emi_grd      
c-------------------------------------------------------------------------------
c   Local Sizes
c-------------------------------------------------------------------------------
      integer :: ixloc, iyloc
      integer :: bounds(8)
c-------------------------------------------------------------------------------
c   MPI-realated declarations
c-------------------------------------------------------------------------------
      integer :: status(MPI_STATUS_SIZE)
      integer :: ierr, rc
      double precision :: StartTime, EndTime
c-------------------------------------------------------------------------------
c   Checkpoint-realated declarations
c-------------------------------------------------------------------------------
      integer :: record_no_conc = 0, unit_chkp2_conc = 85
      integer :: record_no_meteo = 0, unit_chkp2_meteo = 86
      integer :: record_no_airh = 0, unit_chkp2_airh = 87
      integer :: record_no_airv = 0, unit_chkp2_airv = 88
     
c-------------------------------------------------------------------------------
c  Coordinates
c-------------------------------------------------------------------------------
      integer :: vert_coord
      integer, parameter :: z_coord=1, sigma_coord=2
      vert_coord = z_coord

c                                                                     
c-------------------------------------------------------------------------------
c   Initialize MPI Stuff
c-------------------------------------------------------------------------------
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, MyId, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, Nprocs, ierr )
c-------------------------------------------------------------------------------
c    The data mapping scheme, communciation pattern, initialization
c-------------------------------------------------------------------------------
      call init_hv(ix,iy,iz,izloc,icloc,N_gas)
c-------------------------------------------------------------------------------
c    Check if not enough or too many workers
c-------------------------------------------------------------------------------
      if (Nprocs<=1) then
         print*,'There are only ',Nprocs-1,' worker(s),'
         print*,'   not enough for parallelization!'
	 goto 100
      else if (Nprocs-1>max(iz,ix*iy)) then
         print*,'There are ',Nprocs-1,' workers ',
     &        'and only ',iz,' h-slices, ',ix*iy,' v-columns.'
         print*,'Some workers will go to unemployment !' 
      end if	 
		                                                      
c----------------------------------------------------------------------c
c                      Allocate memory                                 c
c----------------------------------------------------------------------c
      if (Master) then
       call MemAlloc( ix, iy, iz, N_gas, N_liquid, N_particle, 
     &                 sg1, sl1, sp1, u, v, w, kh, kv, 
     &                 t, dz, wc, wr2, sprc, rvel, 
     &                 sx, sy, sz, q, em, vg, fz, hdz,
     &                 h, deltah, tlon, tlat, cldod, kctop, 
     &                 ccover, dobson)
       call MemAlloc( 1,1,1,1,1,1,
     &                 sg1_v, sl1_v, sp1_v, u_v, v_v, w_v, kh_v, kv_v, 
     &                 t_v, dz_v, wc_v, wr_v, sprc_v, rvel_v, 
     &                 sx_v, sy_v, sz_v, q_v, em_v, vg_v, fz_v, hdz_v,
     &                 h_v, deltah_v, tlon_v, tlat_v, cldod_v, 
     &                 kctop_v, ccover_v, dobson_v)
       call MemAlloc( 1,1,1,1,1,1,
     &                 sg1_h, sl1_h, sp1_h, u_h, v_h, w_h, kh_h, kv_h, 
     &                 t_h, dz_h, wc_h, wr_h, sprc_h, rvel_h, 
     &                 sx_h, sy_h, sz_h, q_h, em_h, vg_h, fz_h, hdz_h,
     &                 h_h, deltah_h, tlon_h, tlat_h, cldod_h, 
     &                 kctop_h, ccover_h, dobson_h)
       allocate( Lambda(ix,iy,iz,N_gas), STAT=ierr)
       allocate( Lambda_h(1,1,1,1), STAT=ierr)
       allocate( Lambda_v(1,1,1,1), STAT=ierr)
       allocate( Lambda0(ix,iy,iz,N_gas), STAT=ierr)
       allocate( Lambda0_h(1,1,1,1), STAT=ierr)  
       allocate( Lambda0_v(1,1,1,1), STAT=ierr)
       allocate( dc_dq(ix,iy,iz,N_gas), STAT=ierr)
       allocate( dc_dq_h(1,1,1,1), STAT=ierr)
       allocate( dc_dq_v(1,1,1,1), STAT=ierr)
       allocate( dc_dem(ix,iy,iz,N_gas), STAT=ierr)
       allocate( dc_dem_h(1,1,1,1), STAT=ierr)
       allocate( dc_dem_v(1,1,1,1), STAT=ierr) 
       allocate( Aird(ix,iy,iz), STAT=ierr)
       allocate( Aird_h(1,1,1), STAT=ierr)
       allocate( Aird_v(1,1,1), STAT=ierr)
       !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
       allocate(emi_fac(ix,iy,2,1),STAT=ierr)
       allocate(emi_grd(ix,iy,2,1),STAT=ierr)
       !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
      else if (HWorker .or. VWorker) then
       call MemAlloc( 1,1,1,1,1,1,sg1, sl1, sp1, u, v, w, kh, kv, 
     &                 t, dz, wc, wr2, sprc, rvel, 
     &                 sx, sy, sz, q, em, vg, fz, hdz,
     &                 h, deltah, tlon, tlat, cldod, 
     &                 kctop, ccover, dobson)
       call MemAlloc(  1, icloc, iz, N_gas, N_liquid, N_particle, 
     &                 sg1_v, sl1_v, sp1_v, u_v, v_v, w_v, kh_v, kv_v, 
     &                 t_v, dz_v, wc_v, wr_v, sprc_v, rvel_v, 
     &                 sx_v, sy_v, sz_v, q_v, em_v, vg_v, fz_v, hdz_v,
     &                 h_v, deltah_v, tlon_v, tlat_v, cldod_v, 
     &                 kctop_v, ccover_v, dobson_v)
       call MemAlloc( ix, iy, izloc, N_gas, N_liquid, N_particle, 
     &                 sg1_h, sl1_h, sp1_h, u_h, v_h, w_h, kh_h, kv_h, 
     &                 t_h, dz_h, wc_h, wr_h, sprc_h, rvel_h, 
     &                 sx_h, sy_h, sz_h, q_h, em_h, vg_h, fz_h, hdz_h,
     &                 h_h, deltah_h, tlon_h, tlat_h, cldod_h, 
     &                 kctop_h, ccover_h, dobson_h)
       allocate( Lambda(1,1,1,1), STAT=ierr)
       allocate( Lambda_h(ix,iy,izloc,N_gas), STAT=ierr)
       allocate( Lambda_v(1,icloc,iz,N_gas),  STAT=ierr)
       allocate( Lambda0(1,1,1,1), STAT=ierr)
       allocate( Lambda0_h(ix,iy,izloc,N_gas), STAT=ierr)
       allocate( Lambda0_v(1,icloc,iz,N_gas),  STAT=ierr)
       allocate( dc_dq(1,1,1,1), STAT=ierr)
       allocate( dc_dq_h(ix,iy,izloc,N_gas), STAT=ierr)
       allocate( dc_dq_v(1,icloc,iz,N_gas),  STAT=ierr)
       allocate( dc_dem(1,1,1,1), STAT=ierr)
       allocate( dc_dem_h(ix,iy,izloc,N_gas), STAT=ierr)
       allocate( dc_dem_v(1,icloc,iz,N_gas),  STAT=ierr)
       allocate( Aird(1,1,1), STAT=ierr)
       allocate( Aird_h(ix,iy,izloc), STAT=ierr)
       allocate( Aird_v(1,icloc,iz),  STAT=ierr)
      else
       print*,'I am neither Master nor Worker ...'
       goto 123
      endif ! Master
c----------------------------------------------------------------------c
                                                                      
c-------------------------------------------------------------------------------
c                       Start the timer
c-------------------------------------------------------------------------------
      StartTime = MPI_WTIME()
c----------------------------------------------------------------------c
c                  Master Performs Setup Simulation                                 c           
c----------------------------------------------------------------------c
      if (Master) then
        call aq_setp(ix,iy,iz,numl,nbin,ixtrn,iytrn,iztrn,
     1                irxng,irxnl,ixm,iym,izm,ilm,
     2                dx,dy,dht,
     2                sigmaz,baseh,
     3                sg1,sl1,sp1,
     3                u,v,w,kh,kv,t,wc,wr2,sprc,q,em,
     4                vg,fz,sx,sy,sz)
       
        num=numl(1,1)
        call input1(idate,ut,iend,ix,iy,iz,
     1	             t,sg1,sl1,sp1,
     2               tlon,tlat,h,deltah,hdz,dx,dy,dz,dht,
     3               sigmaz,baseh,dtmax,iunit,iout)
        uut=ut 
C ---- Read the initial concentration provided by the simulation subroutine -----
	open( unit=unit_mode, file='TmpMode' )
	read( unit_mode,fmt="(A3)" ) mode
	close( unit_mode )
        print*,'MODUS OPERANDIS = <',mode,'>'
        !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
        costfct=0.0
        emi_grd=0.0
        if (mode == 'fbw' .or. mode == 'fwd') then
          open(unit_emi_fac,file='TmpEmiFac', access='direct',
     &         recl=4*ix*iy*2*1)
          read(unit_emi_fac) emi_fac
          close(unit_emi_fac)
        !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          open(unit_obs1, file='input.dat',status='old')
          read(unit_obs1,*) NUM_obs,NUM_mea
          write(*,*) NUM_obs,NUM_mea
          read(unit_obs1,*) 
          do i_mea=1,NUM_mea
             read(unit_obs1,*) unc_obs(i_mea),NUM_spe(i_mea)
             read(unit_obs1,*) obs_index(i_mea,1:NUM_spe(i_mea))
             print *, unc_obs(i_mea),NUM_spe(i_mea)
             print *, obs_index(i_mea,1:NUM_spe(i_mea))
          enddo
          do i_flt=1,NUM_obs
            read(unit_obs1,*)
     &      f_t(i_flt),f_x(i_flt),f_y(i_flt),
     &      f_obs(i_flt,1:NUM_mea)
            print *, f_t(i_flt),f_x(i_flt),f_y(i_flt),
     &      f_obs(i_flt,1:NUM_mea)
            f_obs_model(i_flt,1:NUM_mea)=0.0
          enddo
          do i_mea=1, NUM_mea
             ave_obs(i_mea)=0.0
             count_valid(1:NUM_mea)=0.0
             do i_flt=1,NUM_obs
                if(f_obs(i_flt,i_mea).gt.0.0) then
                  count_valid(i_mea)=count_valid(i_mea)+1.0
                  ave_obs(i_mea)=ave_obs(i_mea)+f_obs(i_flt,i_mea) 
                  !print *, i_flt, count_valid(i_mea), ave_obs(i_mea)
                endif
             enddo
             ave_obs(i_mea)=ave_obs(i_mea)/count_valid(i_mea)
             print *, i_mea, obs_index(i_mea,1:NUM_spe(i_mea)), 
     &                count_valid(i_mea), ave_obs(i_mea) 
          enddo 
           
         close(unit_obs1)
        end if
      endif ! Master

C --------------------------------------------------------------------------------

      costfct=0d0 

      call MPI_BCAST(mode,3,MPI_CHARACTER,0,MPI_COMM_WORLD,ierr) ! broadcast mode
      if (mode=='ini') goto 123

     
      call int_distrib1(iend)

c----------------------------------------------------------------------c
c                   Open a checkpoint file                             c
c----------------------------------------------------------------------c
      if (VWorker.and.mode=='fbw') then
	! Name of the local checkpoint file
         print*,MyId,' begins opening chkpt ',fname_chkp2
         print*, 'icloc,iz,N_gas', icloc,iz,N_gas  
        call open_chkp2_conc(MyId,unit_chkp2_conc,
     &         fname_chkp2,icloc*iz*N_gas)
      end if
c----------------------------------------------------------------------c
c    FORWARD  SIMULATION BEGINS HERE    
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
      big_fwd:do it=1,iend
      
c----------------------------------------------------------------------c
c      
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
c
      if (Master) then
c      
        if(idate(1).ne.2004) then
	  print*, 'time error before calling input2'
	  print*, 'idate=',idate
	  print*, 'it,ut=',it,ut
	  stop
	endif
	print*,'Call input2 acquiring time dependent data'
        print*,'int(ut)=', int(ut)
        print*,'ut=', int(ut)
        print*,'int(uut)=', int(uut)
        print*,'uut=', int(uut) 
        call input2(ix,iy,iz,num,int(ut),idate,
     &     sg1,u,v,w,kh,kv,t,
     &	   wc,wr2,rvel,q,em,vg,fz,sprc,
     &     sx,sy,sz,dx,dy,hdz,h,cldod,ccover,kctop,dobson,iunit)
c        
        if (vert_coord==sigma_coord) then	
         call cartesian2sigma(ix,iy,iz,dx(1),dy(1),sigmaz,h, 
     &                       deltah,U,V,W,Kh,Kv)
        end if

        !caca
        print*,'Time idate=',ut,'  u=',u(40,30,2),
     &        '  v=',v(40,30,2),'  w=',w(40,30,2)

        ! Air density
	Aird(1:ix,1:iy,1:iz) = sg1(1:ix,1:iy,1:iz,iair)

        ! Convert B.C.s from molecules/cm3 to molefraction
	 do ispc = 1, num
	 do j=1,iy
	 do k=1,iz
	   sx(j,k,1,ispc) = sx(j,k,1,ispc)/sg1(1,j,k,iair)
	   sx(j,k,2,ispc) = sx(j,k,2,ispc)/sg1(ix,j,k,iair)
	 end do
	 end do
	 do i=1,ix
	 do k=1,iz  
	   sy(i,k,1,ispc) = sy(i,k,1,ispc)/sg1(i,1,k,iair)
	   sy(i,k,2,ispc) = sy(i,k,2,ispc)/sg1(i,iy,k,iair)
	 end do
	 end do
	 do i=1,ix
	 do j=1,iy  
	   sz(i,j,ispc) = sz(i,j,ispc)/sg1(i,j,iz,iair)
	 end do
	 end do
	 end do ! ispc
        
      ! Convert emissions from molecules/cm3 to molefraction
	do ispc = 1, num
	   ! From mlc/cm^2 to parts m
	  q(1:ix,1:iy,ispc) = q(1:ix,1:iy,ispc)/
     &                      sg1(1:ix,1:iy,1,iair)/100
          em(1:ix,1:iy,1:iz,ispc) =  em(1:ix,1:iy,1:iz,ispc)/
     &                      sg1(1:ix,1:iy,1:iz,iair)
	end do ! ispc
       !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
       do i=1,ix
       do j=1,iy
          !iit=mod(it,24)
          !if(iit<1) iit=24
          iit=1  
          q(i,j,1)=q(i,j,1)*emi_fac(i,j,1,iit)
          em(i,j,2:iz,1)=em(i,j,2:iz,1)*emi_fac(i,j,2,iit)
       enddo
       enddo
       
       !q(1:ix,1:iy,1)=q(1:ix,1:iy,1)*
       !em(1:ix,1:iy,1:iz,1)=em(1:ix,1:iy,1:iz,1)*fac_emi
       !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

        ! Convert initial concentrations from molecules/cm3 to molefraction
        if (it==1) then
           call conv_conc(ix*iy*iz,num,sg1,
     &                   sg1(1,1,1,iair),rmw,iair,8)
!        sg1(1:ix,1:iy,1:iz,1:num)=sg1(1:ix,1:iy,1:iz,1:num)/1.e9 
!        !From ppb to molfraction
        end if
	 
        mdt = 4
        dt  = 450.0 ! seconds
c     
      endif  !  Master

c-----------------------------------------------------------------------
c     Master Distributes data 
c-----------------------------------------------------------------------
c      
      call int_distrib2(numl,nbin,ixtrn,iytrn,iztrn,
     &                  irxng,irxnl,num,mdt,idate,iend)
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
      call real_distrib(ix,iy,iz,is,dx,dy,sigmaz,
     &                  dht,baseh,rmw,dt,ut) 
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
      call cmm_distrib() 
     
     
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
      if(Master) print*,'Start Distribution Concentrations'

      ! Distribute initial conditions
      call distrib_h_4D(ix,iy,iz,izloc,N_gas,sg1,sg1_h)     
 
      if (it==1) then
        ! Distribute topographical Data
          if(Master) print*,'Start Distribution Topo'
          call distrib_topo_hv( ix,iy,iz,izloc,icloc,
     &                   hdz, hdz_h, hdz_v, 
     &                   h,   h_v, 
     &                   deltah, deltah_v,
     &                   tlon, tlon_v,
     &                   tlat, tlat_v, 
     &                   dz, dz_h, dz_v )
      end if
       
      if(Master) print*,'Start Distribution Other Stuff'

      call distrib_hv( ix,iy,iz,izloc,icloc,
     &                   N_gas, N_liquid, N_particle,
     &                   u, v, w, u_h, v_h, w_v,
     &                   kh, kv, t, kh_h, kv_h, t_h, kh_v, kv_v, t_v,
!     &                   aird, aird_h, aird_v,
     &                   wc, wc_h, wc_v, wr2, wr_h, wr_v,
     &                   rvel, rvel_h, rvel_v,
     &                   q, q_v, sprc, sprc_v,
     &                   em, em_h, em_v,
     &                   vg, vg_h, vg_v, fz, fz_h, fz_v,
     &                   sx, sx_h, sy, sy_h, sz, sz_v,
     &                   cldod, cldod_h, cldod_v,
     &                   kctop, kctop_h, kctop_v,
     &                   ccover, ccover_h, ccover_v,
     &                   dobson, dobson_h, dobson_v )
c 
      ! Distribute Air density
      call distrib_h_3D(ix,iy,iz,izloc,Aird,Aird_h)
      call distrib_v_3D(ix,iy,iz,icloc,Aird,Aird_v)
 
      if(Master) print*,'Start Small time-split steps'

 
c-----------------------------------------------------------------------
c     START SMALL TIME-SPLIT STEPS 
      small_fwd: do iter=1,mdt
c-----------------------------------------------------------------------
 
c
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
c     
      if (HWorker) then
         bounds=(/1,ix,1,iy,1,no_of_hslices(MyId),1,num/)	   
         if (ixtrn.eq.0) then
            call tranx_mf(ix,iy,izloc,bounds,sg1_h,u_h,
     &                kh_h,sx_h,dt,dx)     
         endif ! ixtrn.eq.0
         if (iytrn.eq.0) then ! Y-Transport
            call trany_mf(ix,iy,izloc,bounds,sg1_h,v_h,
     &                    kh_h,sy_h,dt,dy)
         endif ! iytrn.eq.0
       endif ! HWorker
       
 
c----------------------------------------------------------------------------------------------
        if(Master) print*,'h2v'
c              Change data format from x-slices to y-slices 
         call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
         call shuffle_h2v_4D(ix,iy,iz,izloc,icloc,N_gas,sg1_h,sg1_v)  
c----------------------------------------------------------------------------------------------- 
	 	 
      if (VWorker) then
	 
	 if (iztrn.eq.0) then 
	     bounds=(/1,1,1,no_of_vcols(MyId),1,iz,1,num/)
	     if (vert_coord == z_coord) then
	        call tranz_mf(1,icloc,iz,bounds,sg1_v,w_v,kv_v,
     &                  q_v,em_v,vg_v,sz_v,dt,dz_v)
	     else if (vert_coord == sigma_coord) then
	        call tranz_sigma_mf(1,icloc,iz,bounds,sg1_v,w_v,
     &                  kv_v,q_v,em_v,vg_v,sz_v,dt,sigmaz)
	     end if	   
	 endif ! iztrn.eq.0

c  ----------------------------------------------------------------------------------------------
c    Write the checkpoints
         if(mode=='fbw') then
           record_no_conc = record_no_conc + 1
	   call write_4D_chkp2(1,icloc,iz,N_gas,sg1_v,
     &                   record_no_conc,unit_chkp2_conc)
         endif
c  ----------------------------------------------------------------------------------------------
	 
*******Begin chemical calculation	 
         if (irxng.eq.0) then 
	    bounds=(/1,1,1,no_of_vcols(MyId),1,iz,1,num/)
            call conv_conc(icloc*iz,num,sg1_v,
     &                  sg1_v(1,1,1,iair),rmw,iair,7)
            call rxn(1,icloc,iz,bounds,idate,ut,2*dt,tlon_v,tlat_v,
     &                h_v,hdz_v,sg1_v,sl1_v,sp1_v,t_v,
     &                wc_v,wr_v,sprc_v,rvel_v,cldod_v,
     &                kctop_v,ccover_v,dobson_v)
            call conv_conc(icloc*iz,num,sg1_v,
     &                  sg1_v(1,1,1,iair),rmw,iair,8)
         endif ! (irxng.eq.0)
c
********end chemical calculation 
c	 
	 if (iztrn.eq.0) then 
	     bounds=(/1,1,1,no_of_vcols(MyId),1,iz,1,num/)
	     if (vert_coord == z_coord) then
	        call tranz_mf(1,icloc,iz,bounds,sg1_v,w_v,kv_v,
     &                  q_v,em_v,vg_v,sz_v,dt,dz_v)
	     else if (vert_coord == sigma_coord) then
	        call tranz_sigma_mf(1,icloc,iz,bounds,sg1_v,w_v,
     &                  kv_v,q_v,em_v,vg_v,sz_v,dt,sigmaz)
	     end if	   
	 endif ! iztrn.eq.0
c	 
       endif ! VWorker
       	 
c  ----------------------------------------------------------------------------------------------
c              Change data format from y-slices to x-slices 
         if(Master) print*,'v2h'
         call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
         call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,N_gas,sg1_h,sg1_v)  
c  ----------------------------------------------------------------------------------------------
      if (HWorker) then
         bounds=(/1,ix,1,iy,1,no_of_hslices(MyId),1,num/)	   
         if (iytrn.eq.0) then ! Y-Transport
            call trany_mf(ix,iy,izloc,bounds,sg1_h,v_h,
     &                    kh_h,sy_h,dt,dy)
         endif ! iytrn.eq.0
         if (ixtrn.eq.0) then
            call tranx_mf(ix,iy,izloc,bounds,sg1_h,u_h,
     &                kh_h,sx_h,dt,dx)     
         endif ! (ixtrn.eq.0)
      endif ! HWorker

      ut=ut+2.*dt/3600.0
      uut=uut+2.*dt/3600.0
      if (Master) then
        call aq_clock_n(idate,ut)
        write(6,*) 'idate=',idate,'   ut=',ut
        write(6,*) 'uut=',uut 
      endif ! Master	

c------------------------------------------------------------------------
c    Master Process Gets Concentration Data From Workers
c------------------------------------------------------------------------
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
      if(Master)  print*,'Master Gathers Data'
      call gather_h_4D(ix,iy,iz,izloc,N_gas,sg1,sg1_h)
c=================================================================
      if(Master) then
        call conv_conc(ix*iy*iz,num,sg1,
     &   sg1(1,1,1,iair),rmw,iair,7)

        do i_flt=1, NUM_obs
         t_obs=f_t(i_flt)
         if(abs(t_obs-uut).le.(2.*dt/3600.0)) then
         !if((t_obs.lt.(uut+1.0)).and.(uut.le.t_obs)) then
           if(t_obs.ge.uut) ft_obs=(1.0 - (t_obs-uut)/2./dt*3600.)
           if(t_obs.lt.uut) ft_obs=(1.0 - (uut-t_obs)/2./dt*3600.)
           !ft_obs=2.0*dt/3600.0 !0.25
           ix_obs=int(f_x(i_flt))
           iy_obs=int(f_y(i_flt))
           !iz_obs=int(f_z(i_flt))
           fx_obs=f_x(i_flt)-ix_obs
           fy_obs=f_y(i_flt)-iy_obs
           do i_z=1,iz-1
           ! Checking index later is done in the preprocesor,
           ! which is used to generate "flight.dat" TO_DO
           do i_mea=1,NUM_mea
            !f_obs_model(i_flt,i_mea)=0.0 
            do i_spe=1,NUM_spe(i_mea) 
              i_sg1=obs_index(i_mea,i_spe)
              tri_linear=sg1(ix_obs,iy_obs,i_z,i_sg1)        !Point 000
     &                   *(1.-fx_obs)*(1.-fy_obs)*dz(ix_obs,iy_obs,i_z)
     &                 + sg1(ix_obs+1,iy_obs,i_z,i_sg1)      !Point 100 
     &                 *fx_obs*(1.-fy_obs)*dz(ix_obs+1,iy_obs,i_z)
     &                 + sg1(ix_obs,iy_obs+1,i_z,i_sg1)      !Point 010
     &                 *(1.-fx_obs)*fy_obs*dz(ix_obs,iy_obs+1,i_z)
     &                 + sg1(ix_obs+1,iy_obs+1,i_z,i_sg1)    !Point 110   
     &                 *fx_obs*fy_obs*dz(ix_obs+1,iy_obs+1,i_z)
              f_obs_model(i_flt,i_mea)= f_obs_model(i_flt,i_mea)
     &         + ft_obs*tri_linear*100/1e14   ! convert to 10^14 molecules/cm2
            enddo !i_spe
           enddo  !i_mea
          enddo  !i_z 
         endif   !t_obs 
	enddo 
        call conv_conc(ix*iy*iz,num,sg1,
     &   sg1(1,1,1,iair),rmw,iair,8)

      endif !Master
c=================================================================
c
c------------------------------------------------------------------------
      end do small_fwd
c    END SMALL FORWARD TIME-SPLIT STEPS
c------------------------------------------------------------------------
      if(Master)  print*,'Small forward time-split steps end'
      ut = nint(ut)
      if (Master) then
        call aq_clock_n(idate,ut)
        write(6,*) 'idate=',idate,'   ut=',ut
        write(6,*) 'idate=',idate,'   uut=',uut
      endif ! Master     
c------------------------------------------------------------------------
c    Master Process Prints Data
c------------------------------------------------------------------------
      if (Master) then
        if (mod(it,iprnt).eq.0) then
          !call prtout(idate,ut,ix,iy,iz,sg1,sl1,iout)
          call plot_spc('GRO3',ix,iy,iz,it,sg1)
        endif
        if (mod(it,jprnt).eq.0) then
          ! call prjout(idate,ut,ix,iy,iz,sg1,sl1,iout)
        endif
        if (mod(it,iaeroprnt).eq.0) then
          ! call praero(idate,ut,ix,iy,iz,sg1,sl1,iout)
        endif
        if (mod(it,iscrat).eq.0) then 
          ! call prtemp(idate,ut,ix,iy,iz,sg1,sl1,iout)
        endif

      endif ! Master
c     
      if(Master)  print*,'Big forward time steps steps end'
c-----------------------------------------------------------------------c
      end do big_fwd  ! end of Big Loop
c       FORWARD SIMULATION ENDS HERE                                    c
c-----------------------------------------------------------------------c
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr) 
      if(Master)  then
        print*,'sg1(1,30,2,1)' 
        !costfct=(sg1(1,30,2,1)-1e-13)**2 / 1e-28
        write(*,*) 'Before write costfct:', costfct
        open(unit=unit_cost, file='costfct' )
        write( unit_cost,*) costfct
        close( unit_cost )
        write(*,*) 'After writing the file'
      endif
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
           
      ! print*,'RECORD=',record_no_conc,mdt*iend
      
      if(.true.) then 
      if (Master) then
        costfct=0.0
        open(unit=unit_pred1,file='t_obs_pred.dat')
        print *,'==================================================='
        do i_flt=1,NUM_obs
           write(unit_pred1,('3e13.5')) 
     &       f_t(i_flt),f_obs(i_flt,1:NUM_mea),
     &       f_obs_model(i_flt,1:NUM_mea)
           do i_mea=1,NUM_mea
              if(f_obs(i_flt,i_mea).ge.0.) then
               print *,i_mea,f_obs(i_flt,i_mea),f_obs_model(i_flt,i_mea)
               print *, 'costfct=', costfct
               costfct=costfct+
     &         (f_obs_model(i_flt,i_mea)-f_obs(i_flt,i_mea))**2/2.
     &          /( (unc_obs(i_mea)*ave_obs(i_mea))**2 )           
               endif
           enddo
      !   Forcing should be in the units of ratio, output
      !   files are written in "ppbv" following convention. 
        enddo  
        print *, 'costfct=', costfct 
        print *,'===================================================' 
        close(unit_pred1)

        write(*,*) 'Before write costfct:', costfct
        open(unit=unit_cost, file='costfct' )
        write( unit_cost,*) costfct
        close( unit_cost )
        write(*,*) 'After writing the file' 
      endif
      endif


      if ( mode =='fwd') go to 123 
      !goto 123
      !==================================
      record_no_conc = iend*mdt 

      if(Master) then
c-------Open the adjoint file to write the results in 
        fname_lambda = 'TmpEmiGrd'
        call open_chkp2_conc(0,unit_lambda,fname_lambda,ix*iy*iz*N_gas)
        emi_grd=0.0
        Lambda(1:ix,1:iy,1:iz,1:N_gas) = 0.0 
        dc_dq(1:ix,1:iy,1:iz,1:N_gas) = 0.0
        dc_dem(1:ix,1:iy,1:iz,1:N_gas) = 0.0
      endif

c----------------------------------------------------------------------c
c     BACKWARDS SIMULATION BEGINS HERE   
      big_adj: do it=iend,1,-1
c----------------------------------------------------------------------c
      
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
c
      if (Master) then
c      
	print*,'Call input2 in backwards loop'        
	
	! Time for input2 = time at the beginning of forward it loop
	ut = nint(ut-1); call aq_clock_n(idate,ut)
        uut=uut-1.0
c
        print*,'int(ut)=', int(ut)
        print*,'ut=', int(ut)
        print*,'uut=',int(uut) 

        call input2(ix,iy,iz,num,int(ut),idate,
     &     sg1,u,v,w,kh,kv,t,
     &	   wc,wr2,rvel,q,em,vg,fz,sprc,
     &     sx,sy,sz,dx,dy,hdz,h,cldod,ccover,kctop,dobson,iunit)
c
                
        !caca
        print*,'Time idate=',ut,'  u=',u(40,30,2),
     &        '  v=',v(40,30,2),'  w=',w(40,30,2)

        ! Set the clock back for the rest of the calculations
        ut = real(nint(ut+1)); call aq_clock_n(idate,ut)
        uut=uut+1.0
 
        if (vert_coord==sigma_coord) then	
         call cartesian2sigma(ix,iy,iz,dx(1),dy(1),sigmaz,h, 
     &                       deltah,U,V,W,Kh,Kv)
        end if

        ! Air density
	Aird(1:ix,1:iy,1:iz) = sg1(1:ix,1:iy,1:iz,iair)
c        
        ! Convert B.C.s from molecules/cm3 to molefraction
	 do ispc = 1, num
	 do j=1,iy
	 do k=1,iz
	   sx(j,k,1,ispc) = sx(j,k,1,ispc)/sg1(1,j,k,iair)
	   sx(j,k,2,ispc) = sx(j,k,2,ispc)/sg1(ix,j,k,iair)
	 end do
	 end do
	 do i=1,ix
	 do k=1,iz  
	   sy(i,k,1,ispc) = sy(i,k,1,ispc)/sg1(i,1,k,iair)
	   sy(i,k,2,ispc) = sy(i,k,2,ispc)/sg1(i,iy,k,iair)
           !=================================================
	   ! sx, sy, sz are treated as lambda BC rather than
           ! those of the original concentrations. 11/21 Chai
           !=================================================
	 end do
	 end do
	 do i=1,ix
	 do j=1,iy  
	   sz(i,j,ispc) = sz(i,j,ispc)/sg1(i,j,iz,iair)
	 end do
	 end do
	 end do ! ispc
      ! Convert emissions from molecules/cm3 to molefraction
	do ispc = 1, num
	   ! From mlc/cm^2 to parts m
	  q(1:ix,1:iy,ispc) = q(1:ix,1:iy,ispc)/
     &                      sg1(1:ix,1:iy,1,iair)/100
          em(1:ix,1:iy,1:iz,ispc) =  em(1:ix,1:iy,1:iz,ispc)/
     &                      sg1(1:ix,1:iy,1:iz,iair)
	end do ! ispc
       !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
       !Perturb CO emission by 1%
       do i=1,ix
       do j=1,iy
        !iit=mod(it,24)
        !if(iit<1) iit=24
        iit=1
        q(i,j,1)=q(i,j,1)*emi_fac(i,j,1,iit)
        em(i,j,2:iz,1)=em(i,j,2:iz,1)*emi_fac(i,j,2,iit) 
       enddo
       enddo

       print *, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
       print *, 'q(4,6,1),em(4,6,1,1),em(4,6,17,1)'
       print *, q(4,6,1),em(4,6,1,1),em(4,6,17,1)
       print *, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
       !em(1:ix,1:iy,1:iz,1)=em(1:ix,1:iy,1:iz,1)*fac_emi
       !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      endif  !  Master
      !stop	
 
      if(Master) print*,'Distribute stuff in backwards loop'
      call distrib_hv( ix,iy,iz,izloc,icloc,
     &                   N_gas, N_liquid, N_particle,
     &                   u, v, w, u_h, v_h, w_v,
     &                   kh, kv, t, kh_h, kv_h, t_h, kh_v, kv_v, t_v,
!     &                   aird, aird_h, aird_v,
     &                   wc, wc_h, wc_v, wr2, wr_h, wr_v,
     &                   rvel, rvel_h, rvel_v,
     &                   q, q_v, sprc, sprc_v,
     &                   em, em_h, em_v,
     &                   vg, vg_h, vg_v, fz, fz_h, fz_v,
     &                   sx, sx_h, sy, sy_h, sz, sz_v,
     &                   cldod, cldod_h, cldod_v,
     &                   kctop, kctop_h, kctop_v,
     &                   ccover, ccover_h, ccover_v,
     &                   dobson, dobson_h, dobson_v )
c     
      ! Distribute Air density
      call distrib_h_3D(ix,iy,iz,izloc,Aird,Aird_h)
      call distrib_v_3D(ix,iy,iz,icloc,Aird,Aird_v)
      !====================================================
         !NEED TO ADD THE FORCING TERMS      
      !====================================================

      ! Distribute initial conditions
      call distrib_h_4D(ix,iy,iz,izloc,N_gas,Lambda,Lambda_h) 
c-----------------------------------------------------------------------
c     START SMALL ADJOINT TIME-SPLIT STEPS 
      small_adj: do iter=mdt,1,-1
c-----------------------------------------------------------------------
      ! Time in iter adjint loop = time at the beginning of the 
      !  forward iter loop
      !ut=ut-2.*dt/3600.0
      !uut=uut-2.*dt/3600.0
      if (Master) then
        call aq_clock_n(idate,ut)
        write(6,*) 'idate=',idate,'   ut=',ut
        write(6,*) 'uut=',uut 
      endif ! Master	
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
c    
      !================  Add forcing terms begin 3/11/04 ==============
       call gather_h_4D(ix,iy,iz,izloc,N_gas,Lambda,Lambda_h)
       if (Master) then 
         !convert Lambda from 1/mixing_ratio => 1/molecules/cm^3 
         !This is equivalent to convert from molecules/cm^3 to mixing_ratio
         !As both invole the factor of mixing_ratio/(molecules/cm^3)
         call conv_conc(ix*iy*iz,num,Lambda,
     &   sg1(1,1,1,iair),rmw,iair,8)

          do i_flt=1, NUM_obs
             t_obs=f_t(i_flt)
             ix_obs=int(f_x(i_flt))
             iy_obs=int(f_y(i_flt))
             fx_obs=f_x(i_flt)-ix_obs
             fy_obs=f_y(i_flt)-iy_obs
           
             if(abs(t_obs-uut).le.(2.*dt/3600.0)) then
               if(t_obs.ge.uut) ft_obs=(1.0 - (t_obs-uut)/2./dt*3600.)
               if(t_obs.lt.uut) ft_obs=(1.0 - (uut-t_obs)/2./dt*3600.)
               ! Forcing terms hx_m_y : H(x)- y
               ! H projects from model space x to observation space y 

               do i_z=1,iz-1
               do i_mea=1,NUM_mea
               do i_spe=1,NUM_spe(i_mea) 
               if(f_obs(i_flt,i_mea).ge.0.) then
               i_sg1=obs_index(i_mea,i_spe)
               hx_m_y=(f_obs_model(i_flt,i_mea)-f_obs(i_flt,i_mea))
     &               /((unc_obs(i_mea)*ave_obs(i_mea))**2)
               Lambda(ix_obs,iy_obs,i_z,i_sg1)=        !Point 000
     &		  Lambda(ix_obs,iy_obs,i_z,i_sg1)
     &           +ft_obs*(1.-fx_obs)*(1.-fy_obs)*hx_m_y
     &           *dz(ix_obs,iy_obs,i_z)*100/1e14
               Lambda(ix_obs+1,iy_obs,i_z,i_sg1)=      !Point 100 
     &            Lambda(ix_obs+1,iy_obs,i_z,i_sg1)
     &           +ft_obs*fx_obs*(1.-fy_obs)*hx_m_y
     &           *dz(ix_obs+1,iy_obs,i_z)*100/1e14
               Lambda(ix_obs,iy_obs+1,i_z,i_sg1)=      !Point 010
     &            Lambda(ix_obs,iy_obs+1,i_z,i_sg1)
     &           +ft_obs*(1.-fx_obs)*fy_obs*hx_m_y
     &           *dz(ix_obs,iy_obs+1,i_z)*100/1e14
               Lambda(ix_obs+1,iy_obs+1,i_z,i_sg1)=    !Point 110
     &            Lambda(ix_obs+1,iy_obs+1,i_z,i_sg1)
     &           +ft_obs*fx_obs*fy_obs*hx_m_y
     &           *dz(ix_obs+1,iy_obs+1,i_z)*100/1e14
               !No index out of nounds assumed. This can be guanranted
               !in the preprocessing when generating the flight data.
               endif 
               enddo !i_spe
               enddo !i_mea
               enddo !i_z
             endif 
          enddo 
          call conv_conc(ix*iy*iz,num,Lambda,
     &   sg1(1,1,1,iair),rmw,iair,7)
 
       endif ! Master

      ut=ut-2.*dt/3600.0
      uut=uut-2.*dt/3600.0

       call distrib_h_4D(ix,iy,iz,izloc,N_gas,Lambda,Lambda_h) 
      !================  Add forcing terms end here =================== 
 
      if (HWorker) then
         bounds=(/1,ix,1,iy,1,no_of_hslices(MyId),1,num/)	   
         if (ixtrn.eq.0) then
            call tranx_adjoint_mf(ix,iy,izloc,bounds,
     &                Lambda_h,aird_h,u_h,kh_h,sx_h,dt,dx)     
         endif ! (ixtrn.eq.0)
         if (iytrn.eq.0) then ! Y-Transport
            call trany_adjoint_mf(ix,iy,izloc,bounds,
     &                    Lambda_h,aird_h,v_h,kh_h,sy_h,dt,dy)
         endif ! iytrn.eq.0
      endif ! HWorker
c  ----------------------------------------------------------------------------------------------
        if(Master) print*,'h2v adjoint'
         call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
         call shuffle_h2v_4D(ix,iy,iz,izloc,icloc,
     &                        N_gas,Lambda_h,Lambda_v)  
c------------------------------------------------------------------------------------------------- 
	 	 
      if (VWorker) then
	 if (iztrn.eq.0) then 
	     bounds=(/1,1,1,no_of_vcols(MyId),1,iz,1,num/)
	     if (vert_coord == z_coord) then
                Lambda0_v=Lambda_v
	        call tranz_adjoint_mf(1,icloc,iz,bounds,Lambda_v,aird_v,
     &            w_v,kv_v,q_v,em_v,vg_v,sz_v,dt,dz_v,dc_dq_v,dc_dem_v)
	     else if (vert_coord == sigma_coord) then
	        call tranz_sigma_adjoint_mf(1,icloc,iz,bounds,Lambda_v,
     &                  aird_v,w_v,kv_v,q_v,em_v,vg_v,sz_v,dt,sigmaz)
	     end if	   
	 endif ! iztrn.eq.0
      endif !VWorker
c  --------------------------------------------------------------------
   !ADD  emi_grd caculation 
   !=======================
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,
     &                        N_gas,Lambda0_h,Lambda0_v)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr) 
       call gather_h_4D(ix,iy,iz,izloc,N_gas,Lambda0,Lambda0_h)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,
     &                        N_gas,dc_dq_h,dc_dq_v)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call gather_h_4D(ix,iy,iz,izloc,N_gas,dc_dq,dc_dq_h)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,
     &                        N_gas,dc_dem_h,dc_dem_v)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr) 
       call gather_h_4D(ix,iy,iz,izloc,N_gas,dc_dem,dc_dem_h) 
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       if(master) then
         do k=1,iz
         !Currently for one speceis (Hg), dF/dc=q_0*dF/dq  
         emi_grd(1:ix,1:iy,1,1)=emi_grd(1:ix,1:iy,1,1)
     &  +q(1:ix,1:iy,1)*Lambda0(1:ix,1:iy,k,1)*dc_dq(1:ix,1:iy,k,1)
         emi_grd(1:ix,1:iy,2,1)=emi_grd(1:ix,1:iy,2,1)
     &  +Lambda0(1:ix,1:iy,k,1)*dc_dem(1:ix,1:iy,k,1)
         enddo
       endif
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr) 
c  --------------------------------------------------------------------
    
      if (VWorker) then  
c  --------------------------------------------------------------------
c    Read the checkpoints
	 call read_4D_chkp2(1,icloc,iz,N_gas,sg1_v,
     &                   record_no_conc,unit_chkp2_conc)
         record_no_conc = record_no_conc - 1
c  --------------------------------------------------------------------
*******Begin chemical calculation	 
         if (irxng.eq.0) then 
	    bounds=(/1,1,1,no_of_vcols(MyId),1,iz,1,num/)
            call conv_conc(icloc*iz,num,sg1_v,
     &                  sg1_v(1,1,1,iair),rmw,iair,7)
c=============================================================
            ! conc scales (*A) => Lambda scales (/A)
            ! Now: cost function is molefraction^2, control
            !     is molefraction, so the adjoint is having 
            !    same unit as concentration, i.e. molefraction
c=============================================================
            call conv_conc(icloc*iz,num,Lambda_v,
     &                  sg1_v(1,1,1,iair),rmw,iair,7)
            call rxn_adjoint(1,icloc,iz,bounds,idate,ut,2*dt,
     &                tlon_v,tlat_v,
     &                h_v,hdz_v,sg1_v,Lambda_v,sl1_v,sp1_v,t_v,
     &                wc_v,wr_v,sprc_v,rvel_v,cldod_v,
     &                kctop_v,ccover_v,dobson_v)
            call conv_conc(icloc*iz,num,Lambda_v,
     &                  sg1_v(1,1,1,iair),rmw,iair,8)
            call conv_conc(icloc*iz,num,sg1_v,
     &                  sg1_v(1,1,1,iair),rmw,iair,8)
         endif ! (irxng.eq.0)
c
********end chemical calculation 
c	 
	 if (iztrn.eq.0) then 
	     bounds=(/1,1,1,no_of_vcols(MyId),1,iz,1,num/)
	     if (vert_coord == z_coord) then
                Lambda0_v=Lambda_v
	        call tranz_adjoint_mf(1,icloc,iz,bounds,Lambda_v,aird_v,
     &           w_v,kv_v,q_v,em_v,vg_v,sz_v,dt,dz_v,dc_dq_v,dc_dem_v)

	     else if (vert_coord == sigma_coord) then
	        call tranz_sigma_adjoint_mf(1,icloc,iz,
     &                  bounds,Lambda_v,aird_v,w_v,
     &                  kv_v,q_v,em_v,vg_v,sz_v,dt,sigmaz)
	     end if	   
	 endif ! iztrn.eq.0
c	 
       endif ! VWorker
c  --------------------------------------------------------------------
   !ADD  emi_grd caculation
   !=======================
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,
     &                        N_gas,Lambda0_h,Lambda0_v)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call gather_h_4D(ix,iy,iz,izloc,N_gas,Lambda0,Lambda0_h)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,
     &                        N_gas,dc_dq_h,dc_dq_v)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call gather_h_4D(ix,iy,iz,izloc,N_gas,dc_dq,dc_dq_h)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,
     &                        N_gas,dc_dem_h,dc_dem_v)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       call gather_h_4D(ix,iy,iz,izloc,N_gas,dc_dem,dc_dem_h)
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
       if(master) then
         do k=1,iz
         !Currently for one speceis (Hg), dF/dc=q_0*dF/dq
         emi_grd(1:ix,1:iy,1,1)=emi_grd(1:ix,1:iy,1,1)
     &  +q(1:ix,1:iy,1)*Lambda0(1:ix,1:iy,k,1)*dc_dq(1:ix,1:iy,k,1)
         emi_grd(1:ix,1:iy,2,1)=emi_grd(1:ix,1:iy,2,1)
     &  +Lambda0(1:ix,1:iy,k,1)*dc_dem(1:ix,1:iy,k,1)
         enddo
       endif
       call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
c  --------------------------------------------------------------------
c  ----------------------------------------------------------------------------------------------
c              Change data format from y-slices to x-slices 
         if(Master) print*,'v2h adjoint'
         call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
         call shuffle_v2h_4D(ix,iy,iz,izloc,icloc,
     &	                      N_gas,Lambda_h,Lambda_v)  
c  ---------------------------------------------------------------------

      if (HWorker) then
         bounds=(/1,ix,1,iy,1,no_of_hslices(MyId),1,num/)	   
         if (iytrn.eq.0) then ! Y-Transport
            call trany_adjoint_mf(ix,iy,izloc,bounds,
     &                    Lambda_h,aird_h,v_h,kh_h,sy_h,dt,dy)
         endif ! iytrn.eq.0
         if (ixtrn.eq.0) then
            call tranx_adjoint_mf(ix,iy,izloc,bounds,
     &                Lambda_h,aird_h,u_h,kh_h,sx_h,dt,dx)     
         endif ! (ixtrn.eq.0)
      endif ! HWorker
c-----------------------------------------------------------------------
      end do small_adj
c     END SMALL ADJOINT TIME-SPLIT STEPS 
c-----------------------------------------------------------------------

c------------------------------------------------------------------------
c    Master Process Gets Adjoint Data From Workers
c------------------------------------------------------------------------
      call MPI_BARRIER(MPI_COMM_WORLD, Ierr)
      call gather_h_4D(ix,iy,iz,izloc,N_gas,Lambda,Lambda_h)
      !============== CHANGES 12/12/03 Tianfeng Chai ============
      call gather_h_4D(ix,iy,iz,izloc,N_gas,sg1,sg1_h)!For forcing terms
c------------------------------------------------------------------------
c    Master Process Prints Data
c------------------------------------------------------------------------
      if (Master) then
	if (mod(it,iprnt).eq.0) then
	   !call prtchkp1(idate,ut,ix,iy,iz,numl(1,3),Lambda)
	endif
      endif ! Master

      
c----------------------------------------------------------------------c
      end do big_adj
c     BACKWARDS SIMULATION ENDS HERE                                  c
c----------------------------------------------------------------------c

c      call close_ioap
 100  continue

c----------------------------------------------------------------------c
c               Delete the checkpoint file                             c
c----------------------------------------------------------------------c
      if (VWorker) then
	 if ( mode == 'fbw' ) then
	  call rm_chkp2_conc(MyId,unit_chkp2_conc,
     &         fname_chkp2)
	 end if
      end if

c-------------------------------------------------------------------------------
c    Stop the timer
c-------------------------------------------------------------------------------
      EndTime = MPI_WTIME()-StartTime
      if (Master) then
        !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
        open(unit_emi_grd,file='TmpEmiGrd', access='direct',
     &         recl=4*ix*iy*2*1)
        write(unit_emi_grd) emi_grd
        close( unit_emi_grd)

        write(*,*) 'Before write costfct:', costfct
        open(unit=unit_cost, file='costfct' )
        write( unit_cost,*) costfct
        close( unit_cost )
        write(*,*) 'After writing the file'
	!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	print*,'MAX LAMBDA = ',
     &     maxval(Lambda(1:ix,1:iy,1:iz,1:N_gas)),
     &   ' at ',maxloc(Lambda(1:ix,1:iy,1:iz,1:N_gas))
	!call plot_spc('Lfun',ix,iy,iz,numl(1,3),Lambda)
      endif ! Master
       ! print("('Proc[',I2,'] Total Time = ',F9.2,' min.')"),
       !&      MyId,EndTime/60.0    
c      
        print*,'Lambda(20,23,1,4)=', Lambda(20,23,1,4)
123   continue
      EndTime = MPI_WTIME()-StartTime
      if (Master) then
	print("('END STEM. CPU TIME = ',F8.2,' min')"),
     &         EndTime/60.0
      end if 
      call MPI_FINALIZE(Ierr)
      return       
c      
      end program aq_driver_function


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      subroutine plot_spc(name,ix,iy,iz,is,sg1)
      integer Np,ix,iy,iz,is,ixtrn,iytrn,iztrn,irxng
      real sg1(ix,iy,iz,*)
      integer ispc
      character(len=4) :: c, name
      write(c,"(I4)") 1000+is
      open(10,file=
     & '/home/tchai/Icartt/Stem_mul/'//name//'_hr'//c(3:4)//'.dat')
      write(10,"(E14.7)") ((sg1(i,j,1,1),i=1,ix),j=1,iy)
      close(10)
      return
      end
